# frozen_string_literal: true

module HistoricalTextConverter
  module Parsers
    module EEBO
      # Builds inline Document nodes from the contents of a TEI element.
      #
      # Text is preserved as transcribed. The only whitespace removed is
      # XML formatting: indentation after a newline, and whitespace at the
      # start and end of a block. Printed line breaks remain as "\n".
      class InlineBuilder
        # TCP's display forms for line-end word breaks (HTC-0015).
        LINE_BREAK_GLYPHS = {
          "char:EOLhyphen" => "∣",
          "char:EOLunhyphen" => "¦"
        }.freeze

        # Elements TCP places on a line of their own between printed lines.
        OWN_LINE_ELEMENTS = %w[pb note].freeze

        def initialize
          @note_count = 0
        end

        # Returns [inline nodes, notes], where notes are [id, element] pairs
        # for each note referenced from the element, in document order.
        def build(element)
          notes = []
          children = strip_edge(strip_edge(merge(inlines(element, notes)), :start), :end)
          [children, notes]
        end

        def gap(element)
          metadata = {gap: true, reason: element["reason"], extent: element["extent"]}.compact
          Document::Text.new(element.xpath("desc").text.strip, metadata: metadata)
        end

        def page_break(element)
          metadata = {facs: element["facs"]}.compact
          metadata[:additions] = true if element["rendition"] == "simple:additions"
          Document::PageBreak.new(page: element["n"], metadata: metadata)
        end

        def clean(string)
          string.gsub(/\n[ \t]+/, "\n")
        end

        private

        def inlines(element, notes)
          element.children.flat_map { |node| inline(node, notes) }
        end

        def inline(node, notes)
          return text(after_own_line_element(node)) if node.text? || node.cdata?
          return [] unless node.element?

          case node.name
          when "hi" then [styled(node, notes)]
          when "g" then text(LINE_BREAK_GLYPHS.fetch(node["ref"], node.content))
          when "gap" then [gap(node)]
          when "pb" then [page_break(node)]
          when "note" then [note_reference(node, notes)]
          when "expan" then [expansion(node)]
          when "seg" then inlines(node, notes)
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

        def styled(element, notes)
          children = merge(inlines(element, notes))
          return Document::Superscript.new(children: children) if element["rend"] == "sup"

          Document::Emphasis.new(children: children, metadata: {rend: element["rend"]}.compact)
        end

        def note_reference(element, notes)
          @note_count += 1
          id = "note-#{@note_count}"
          notes << [id, element]
          Document::NoteReference.new(target: id)
        end

        def expansion(element)
          abbreviation = element.at_xpath("am/g")&.[]("ref") || element.at_xpath("am")&.text&.strip
          expanded = element.at_xpath("ex") ? element.xpath("ex").text : element.text
          metadata = {expansion: true, abbreviation: abbreviation}.compact
          Document::Text.new(clean(expanded), metadata: metadata)
        end

        def unrecognized(element)
          Document::Text.new(clean(element.content), metadata: {unrecognized: element.name})
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
          when Document::Emphasis, Document::Superscript
            children = strip_edge(node.children, edge)
            return [nil, true] if children.empty?

            [node.with(children: children), children.all? { |child| child.text.empty? }]
          else
            [node, true]
          end
        end
      end
    end
  end
end
