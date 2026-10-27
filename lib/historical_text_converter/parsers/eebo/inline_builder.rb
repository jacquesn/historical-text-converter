# frozen_string_literal: true

module HistoricalTextConverter
  module Parsers
    module EEBO
      # Builds inline Document nodes from TEI running text.
      #
      # Text is preserved as transcribed. The only whitespace removed is
      # XML formatting: indentation after a newline, and whitespace at the
      # start and end of a block. Printed line breaks remain as "\n".
      #
      # Block structures met inside running text, such as a list inside a
      # paragraph, are not built here: #build returns them as block pieces
      # for BlockBuilder, which splits the running text around them
      # (HTC-0018 D9).
      class InlineBuilder
        # TCP's display forms for line-end word breaks (HTC-0015).
        LINE_BREAK_GLYPHS = {
          "char:EOLhyphen" => "∣",
          "char:EOLunhyphen" => "¦"
        }.freeze

        # Elements TCP places on a line of their own between printed lines.
        OWN_LINE_ELEMENTS = %w[pb note].freeze

        # Elements that are blocks even inside running text. A <q> is one
        # too when it holds any of them.
        BLOCK_ELEMENTS = %w[
          ab argument byline cell closer dateline div epigraph figure floatingText fw
          head headnote item l lg list opener p postscript row salute signed sp
          speaker table tailnote trailer
        ].freeze

        # Inline elements marking meaning, built as Spans with these roles
        # (HTC-0018 D7, D13).
        SPAN_ROLES = {
          "q" => :quotation, "bibl" => :citation, "date" => :date,
          "stage" => :stage_direction, "label" => :label, "ref" => :reference,
          "unclear" => :unclear, "add" => :addition, "abbr" => :abbreviation,
          "del" => :deletion, "supplied" => :supplied, "subst" => :substitution,
          "above" => :above, "below" => :below, "sic" => :sic, "corr" => :correction
        }.freeze

        # Attributes kept in a Span's metadata.
        SPAN_ATTRIBUTES = %w[lang rend type reason target].freeze

        # Elements the TCP documents but a 2,300-text sample never showed;
        # each one met is reported (HTC-0018 D13).
        DOCUMENTED_UNOBSERVED = %w[ab fw headnote tailnote del supplied subst sic corr above below].freeze

        # Marks a block element inside running text.
        Embedded = Struct.new(:element)
        private_constant :Embedded

        def initialize(report:, glyphs: GlyphTable.default)
          @report = report
          @glyphs = glyphs
          @note_count = 0
        end

        # Splits running text into pieces, in document order:
        # [:inline, children, notes] for each run of running text, where
        # notes are [id, element] pairs for the notes it refers to, and
        # [:block, element] for each block element within it.
        def build(nodes)
          notes = {}
          pieces = split(inline_nodes(nodes, notes))
          pieces.filter_map do |piece|
            next [:block, piece.element] if piece.is_a?(Embedded)

            children = strip_edge(strip_edge(merge(piece), :start), :end)
            [:inline, children, referenced_notes(children, notes)] unless children.empty?
          end
        end

        def block_element?(node)
          return false unless node.element?
          return true if BLOCK_ELEMENTS.include?(node.name)

          node.name == "q" && node.element_children.any? { |child| block_element?(child) }
        end

        def next_note_id
          @note_count += 1
          "note-#{@note_count}"
        end

        def report_documented(node)
          return unless DOCUMENTED_UNOBSERVED.include?(node.name)

          @report.add(:documented_element, node.name, node.path)
        end

        def gap(element)
          metadata = {artifact: :gap, gap: true, reason: element["reason"], extent: element["extent"]}.compact
          Document::Text.new(element.xpath("desc").text.strip, metadata: metadata)
        end

        def page_break(element)
          metadata = {facs: element["facs"]}.compact
          if element["rendition"] == "simple:additions"
            metadata[:additions] = true
            metadata[:artifact] = :transcriber_addition
          end
          Document::PageBreak.new(page: element["n"], metadata: metadata)
        end

        def milestone_metadata(element)
          {role: :milestone, artifact: :milestone, unit: element["unit"], n: element["n"]}.compact
        end

        def clean(string)
          string.gsub(/\n[ \t]+/, "\n")
        end

        private

        def inlines(element, notes)
          inline_nodes(element.children, notes)
        end

        def inline_nodes(nodes, notes)
          fold_duplicate_pages(nodes.flat_map { |node| inline(node, notes) })
        end

        # A duplicate-page gap is folded into the page break before it, as
        # between blocks (HTC-0016 decision 5).
        def fold_duplicate_pages(stream)
          stream.each_with_object([]) do |node, result|
            index = result.rindex { |prior| !blank_text?(prior) }
            page_break = index && result[index]
            if duplicate_gap?(node) && page_break.is_a?(Document::PageBreak)
              result[index] = page_break.with(metadata: page_break.metadata.with(duplicate: true, artifact: :duplicate_page))
            else
              result << node
            end
          end
        end

        def duplicate_gap?(node)
          node.is_a?(Document::Text) && node.metadata[:gap] && node.metadata[:reason] == "duplicate"
        end

        def blank_text?(node)
          node.is_a?(Document::Text) && node.metadata.empty? && node.value.strip.empty?
        end

        def inline(node, notes)
          return text(after_own_line_element(node)) if node.text? || node.cdata?
          return [] unless node.element?
          return [Embedded.new(node)] if block_element?(node)

          report_documented(node)
          case node.name
          when "hi" then styled(node, notes)
          when "g" then glyph(node)
          when "gap" then [gap(node)]
          when "pb" then [page_break(node)]
          when "note" then [note_reference(node, notes)]
          when "expan" then [expansion(node)]
          when "choice" then choice(node, notes)
          when "seg" then inlines(node, notes)
          when "lb" then [Document::Text.new("\n")]
          when "milestone" then [milestone(node)]
          when "ptr" then [Document::Span.new(role: :pointer, metadata: {target: node["target"]}.compact)]
          when *SPAN_ROLES.keys then span(node, notes)
          else [unrecognized(node)]
          end
        end

        def text(string)
          value = clean(string)
          value.empty? ? [] : [Document::Text.new(value)]
        end

        # An element on its own line between two printed lines is surrounded
        # by two newlines where the print has one. The newline after the
        # element is dropped.
        def after_own_line_element(node)
          element = node.previous_sibling
          return node.content unless element&.element? && OWN_LINE_ELEMENTS.include?(element.name)

          before = element.previous_sibling
          return node.content unless before&.text? && clean(before.content).end_with?("\n")

          node.content.sub(/\A\n/, "")
        end

        # A glyph keeps its own text. An empty glyph takes its display form
        # from the TCP character table, tagged so a transformation can
        # interpret it; one the table lacks is kept as an empty, flagged Text.
        def glyph(element)
          ref = element["ref"]
          return text(LINE_BREAK_GLYPHS[ref]) if LINE_BREAK_GLYPHS.key?(ref)
          return text(element.content) unless element.content.empty?

          display = @glyphs.display(ref)
          return [Document::Text.new(display, metadata: {artifact: :glyph, glyph: ref})] if display

          @report.add(:unknown_glyph, ref.to_s, element.path)
          [Document::Text.new("", metadata: {glyph: ref, unrecognized: "g"}.compact)]
        end

        def styled(element, notes)
          children = inlines(element, notes)
          case element["rend"]
          when "sup" then wrap(children) { |run| Document::Superscript.new(children: run) }
          when "sub" then wrap(children) { |run| Document::Subscript.new(children: run) }
          else
            metadata = {rend: element["rend"]}.compact
            wrap(children) { |run| Document::Emphasis.new(children: run, metadata: metadata) }
          end
        end

        def span(element, notes)
          metadata = SPAN_ATTRIBUTES.to_h { |name| [name.to_sym, element[name]] }.compact
          metadata[:artifact] = :supplied if element.name == "supplied"
          role = SPAN_ROLES.fetch(element.name)
          wrap(inlines(element, notes)) { |run| Document::Span.new(role: role, children: run, metadata: metadata) }
        end

        def milestone(element)
          metadata = milestone_metadata(element)
          Document::Span.new(role: metadata.delete(:role), metadata: metadata)
        end

        def note_reference(element, notes)
          id = next_note_id
          notes[id] = element
          Document::NoteReference.new(target: id)
        end

        def expansion(element, abbreviation: nil)
          abbreviation ||= element.at_xpath("am/g")&.[]("ref") || element.at_xpath("am")&.text&.strip
          expanded = element.at_xpath("ex") ? element.xpath("ex").text : element.text
          metadata = {artifact: :expansion, expansion: true, abbreviation: abbreviation}.compact
          Document::Text.new(clean(expanded).strip, metadata: metadata)
        end

        # An abbreviation with its expansion follows HTC-0016 decision 8; a
        # reading with its correction keeps the reading as printed
        # (HTC-0018 D7, D13).
        def choice(element, notes)
          abbr, expan, sic, corr = %w[abbr expan sic corr].map { |name| element.at_xpath(name) }
          return [expansion(expan, abbreviation: abbr&.text&.strip)] if expan
          return reading(sic, corr, notes) if sic

          @report.add(:unrecognized_element, "choice", element.path)
          inlines(element, notes)
        end

        def reading(sic, corr, notes)
          @report.add(:documented_element, "sic", sic.path)
          metadata = {correction: corr && clean(corr.text).strip}.compact
          wrap(inlines(sic, notes)) { |run| Document::Span.new(role: :sic, children: run, metadata: metadata) }
        end

        def unrecognized(element)
          @report.add(:unrecognized_element, element.name, element.path)
          Document::Text.new(clean(element.content), metadata: {unrecognized: element.name})
        end

        # Builds one wrapper node per run of inline content, keeping any
        # block elements between the runs (HTC-0018 D9).
        def wrap(stream)
          split(stream).map { |piece| piece.is_a?(Embedded) ? piece : yield(merge(piece)) }
        end

        # Splits a stream into runs of inline nodes and the Embedded block
        # elements between them.
        def split(stream)
          stream
            .slice_when { |before, after| before.is_a?(Embedded) || after.is_a?(Embedded) }
            .flat_map { |chunk| chunk.first.is_a?(Embedded) ? chunk : [chunk] }
        end

        def referenced_notes(children, notes)
          children
            .flat_map { |child| child.grep(Document::NoteReference) }
            .map { |reference| [reference.target, notes.fetch(reference.target)] }
        end

        # Joins adjacent plain Text nodes, so words split only by markup
        # (such as a line-end hyphen glyph) form one Text.
        def merge(nodes)
          nodes.each_with_object([]) do |node, merged|
            if plain?(node) && plain?(merged.last)
              merged[-1] = Document::Text.new(merged.last.value + node.value)
            else
              merged << node
            end
          end
        end

        def plain?(node)
          node.is_a?(Document::Text) && node.metadata.empty?
        end

        # Removes whitespace at one edge of the inline content, looking past
        # nodes that carry no text (page breaks, note references).
        def strip_edge(nodes, edge)
          ordered = (edge == :start) ? nodes : nodes.reverse
          stripping = true
          result = ordered.filter_map do |node|
            next node unless stripping

            node, stripping = strip_node(node, edge)
            node
          end
          (edge == :start) ? result : result.reverse
        end

        # Returns the stripped node (nil if nothing remains) and whether
        # stripping should continue to the next node.
        def strip_node(node, edge)
          case node
          when Document::Text
            value = (edge == :start) ? node.value.lstrip : node.value.rstrip
            return [nil, true] if value.empty? && node.metadata.empty?

            [node.with(value: value), value.empty?]
          when Document::NoteReference, Document::PageBreak
            [node, true]
          else
            return [node, true] if node.leaf?

            children = strip_edge(node.children, edge)
            return [nil, true] if children.empty?

            [node.with(children: children), children.all? { |child| child.text.empty? }]
          end
        end
      end
    end
  end
end
