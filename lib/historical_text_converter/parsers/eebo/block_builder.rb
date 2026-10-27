# frozen_string_literal: true

module HistoricalTextConverter
  module Parsers
    module EEBO
      # Builds block Document nodes from TEI <front>, <body>, <group>, and
      # <back>, and from everything they contain.
      class BlockBuilder
        # Elements built as a Paragraph tagged with this role (HTC-0016,
        # HTC-0018 D3, D8, D13).
        ROLE_PARAGRAPHS = {
          "trailer" => :trailer, "bibl" => :citation, "byline" => :byline,
          "salute" => :salute, "signed" => :signed, "dateline" => :dateline,
          "speaker" => :speaker, "stage" => :stage_direction, "label" => :label,
          "fw" => :forme_work, "headnote" => :headnote, "tailnote" => :tailnote,
          "figDesc" => :description
        }.freeze

        # Roles whose paragraphs are not the author's text (HTC-0018 D11).
        ARTIFACT_ROLES = %i[forme_work description].freeze

        # Elements built as a Section of the same kind (HTC-0018 D3).
        SECTION_KINDS = %w[argument opener closer epigraph postscript].freeze

        # The parts of a TEI <text>, as Section kinds.
        PART_KINDS = {"front" => :front_matter, "body" => :body, "back" => :back_matter}.freeze

        # Elements that always begin a block, even standing between blocks.
        BLOCK_LEVEL = (InlineBuilder::BLOCK_ELEMENTS + ROLE_PARAGRAPHS.keys + PART_KINDS.keys +
          %w[q floatingText group text]).uniq.freeze

        # Running-text elements that stand alone when met between blocks.
        MARKERS = %w[pb milestone gap note].freeze

        def initialize(report:)
          @report = report
          @inlines = InlineBuilder.new(report: report)
        end

        def matter(element, kind)
          return Document::Section.new(kind: kind) unless element

          Document::Section.new(kind: kind, children: blocks(element, 0))
        end

        # The body of a TEI <text>: its <body>, or the texts of a <group>
        # volume (HTC-0018 D1).
        def body(text)
          return matter(text.at_xpath("body"), :body) if text.at_xpath("body")

          group = text.at_xpath("group") || raise(ParseError, "No TEI <body> or <group> element found")
          Document::Section.new(kind: :body, children: blocks(group, 0))
        end

        private

        # depth is the number of enclosing <div>s, which sets heading levels.
        def blocks(element, depth)
          blocks_from(element.children, depth)
        end

        # Builds blocks from a node list. Running text directly between
        # blocks is gathered into paragraphs.
        def blocks_from(nodes, depth)
          result = []
          run = []
          nodes.each do |node|
            if node.element? && BLOCK_LEVEL.include?(node.name)
              flush(run, depth, result)
              add_block(node, depth, result)
            elsif marker?(node) && blank?(run) && between_blocks?(node)
              run.clear
              add_marker(node, result)
            else
              run << node
            end
          end
          flush(run, depth, result)
          result
        end

        def blank?(nodes)
          nodes.all? { |node| node.text? && node.content.strip.empty? }
        end

        def marker?(node)
          node.element? && MARKERS.include?(node.name)
        end

        # True when no running text follows the node before the next block,
        # so the node stands between blocks rather than opening a paragraph.
        def between_blocks?(node)
          sibling = node.next_sibling
          while sibling
            return true if sibling.element? && BLOCK_LEVEL.include?(sibling.name)
            return false unless marker?(sibling) || blank?([sibling])

            sibling = sibling.next_sibling
          end
          true
        end

        def flush(run, depth, result)
          result.concat(paragraph_from(run, depth)) unless blank?(run)
          run.clear
        end

        def add_block(node, depth, result)
          @inlines.report_documented(node)
          name = node.name
          case name
          when "div" then result << division(node, depth + 1)
          when "head" then result.concat(heading(node, depth))
          when "p", "ab" then result.concat(paragraph(node, depth))
          when "l" then result.concat(line(node, depth))
          when "lg" then result << poem(node, depth)
          when "list" then result.concat(list(node, depth))
          when "item" then result << list_item(node, depth)
          when "table" then result.concat(table(node, depth))
          when "row" then result << table_row(node, depth)
          when "cell" then result << table_cell(node, depth)
          when "figure" then result << Document::Figure.new(children: blocks(node, depth), metadata: attributes(node))
          when "sp" then result << Document::Speech.new(children: blocks(node, depth), metadata: attributes(node))
          when "q" then result << quotation(node, depth)
          when "floatingText", "text" then result << embedded_text(node, depth)
          when "group" then result << Document::Section.new(kind: :group, children: blocks(node, depth))
          when *PART_KINDS.keys then result << matter(node, PART_KINDS.fetch(name))
          when *SECTION_KINDS then result << section(node, depth)
          when *ROLE_PARAGRAPHS.keys then result.concat(role_paragraph(node, depth))
          end
        end

        def add_marker(node, result)
          case node.name
          when "pb" then result << @inlines.page_break(node)
          when "milestone" then result << Document::Paragraph.new(metadata: @inlines.milestone_metadata(node))
          when "gap" then add_gap(node, result)
          when "note" then result << footnote(@inlines.next_note_id, node)
          end
        end

        def division(element, depth)
          Document::Section.new(
            kind: element["type"]&.to_sym,
            children: blocks(element, depth),
            metadata: attributes(element, "n", "subtype", "rend")
          )
        end

        def section(element, depth)
          Document::Section.new(kind: element.name.to_sym, children: blocks(element, depth), metadata: attributes(element))
        end

        # A heading in a division takes the division's depth; a heading of
        # verse, a list, a table, or a figure is one level below.
        def heading(element, depth)
          level = (%w[div body front back text floatingText].include?(element.parent.name) ? depth : depth + 1)
          metadata = attributes(element, "type")
          container(element.children, depth, metadata) do |children, piece_metadata|
            Document::Heading.new(level: [level, 1].max, children: children, metadata: piece_metadata)
          end
        end

        def paragraph(element, depth, metadata = {})
          paragraph_from(element.children, depth, attributes(element).merge(metadata))
        end

        def paragraph_from(nodes, depth, metadata = {})
          container(nodes, depth, metadata) do |children, piece_metadata|
            Document::Paragraph.new(children: children, metadata: piece_metadata)
          end
        end

        def role_paragraph(element, depth)
          role = ROLE_PARAGRAPHS.fetch(element.name)
          metadata = {role: role}
          metadata[:artifact] = role if ARTIFACT_ROLES.include?(role)
          paragraph(element, depth, metadata)
        end

        def line(element, depth)
          container(element.children, depth, attributes(element, "n")) do |children, piece_metadata|
            Document::Line.new(children: children, metadata: piece_metadata)
          end
        end

        def poem(element, depth)
          Document::Poem.new(children: blocks(element, depth), metadata: attributes(element, "type", "n", "rend"))
        end

        def quotation(element, depth)
          Document::Quotation.new(children: blocks(element, depth), metadata: attributes(element, "rend", "type"))
        end

        # Builds running text, splitting it around any block elements it
        # contains (HTC-0018 D9). Each piece after the first is tagged
        # continued: true, and each note follows the piece that refers to it.
        def container(nodes, depth, metadata)
          @inlines.build(nodes).each_with_index.flat_map do |piece, index|
            next blocks_from([piece[1]], depth) if piece.first == :block

            _, children, notes = piece
            piece_metadata = index.zero? ? metadata : metadata.merge(continued: true)
            [yield(children, piece_metadata), *notes.map { |id, note| footnote(id, note) }]
          end
        end

        def footnote(id, element)
          Document::Footnote.new(children: blocks(element, 0), metadata: {id: id, place: element["place"]}.compact)
        end

        # A list's headings come before it; a label joins the item it
        # precedes (HTC-0018 D4).
        def list(element, depth)
          headings, children = hoist_headings(attach_labels(blocks(element, depth)))
          items = children.map { |child| wrap(child, [Document::ListItem, Document::PageBreak], Document::ListItem) }
          [*headings, Document::List.new(children: items, metadata: attributes(element, "type", "n"))]
        end

        def list_item(element, depth)
          Document::ListItem.new(children: blocks(element, depth), metadata: attributes(element, "n"))
        end

        def attach_labels(children)
          labels = []
          items = children.each_with_object([]) do |child, result|
            if child.is_a?(Document::Paragraph) && child.metadata[:role] == :label
              labels << child
            elsif child.is_a?(Document::ListItem)
              result << child.with(children: labels + child.children)
              labels = []
            else
              result << child
            end
          end
          labels.empty? ? items : items << Document::ListItem.new(children: labels)
        end

        # A table's headings come before it (HTC-0018 D5).
        def table(element, depth)
          headings, children = hoist_headings(blocks(element, depth))
          rows = children.map do |child|
            wrap(child, [Document::TableRow, Document::PageBreak]) do |block|
              Document::TableRow.new(children: [Document::TableCell.new(children: [block])])
            end
          end
          [*headings, Document::Table.new(children: rows, metadata: attributes(element, "rend"))]
        end

        def table_row(element, depth)
          cells = blocks(element, depth).map { |child| wrap(child, [Document::TableCell, Document::PageBreak], Document::TableCell) }
          Document::TableRow.new(children: cells, metadata: attributes(element, "role"))
        end

        def table_cell(element, depth)
          Document::TableCell.new(children: blocks(element, depth), metadata: attributes(element, "role", "rows", "cols"))
        end

        def hoist_headings(children)
          children.partition { |child| child.is_a?(Document::Heading) }
        end

        # Returns child if it is one of the allowed types, otherwise wraps
        # it, so stray content inside a list or table is kept.
        def wrap(child, allowed, wrapper = nil)
          return child if allowed.any? { |type| child.is_a?(type) }
          return wrapper.new(children: [child]) if wrapper

          yield child
        end

        # A volume's texts, and texts set inside a text, keep their own
        # front matter, body, and back matter (HTC-0018 D1).
        def embedded_text(element, depth)
          kind = (element.name == "text") ? :text : (element["type"]&.to_sym || :floating_text)
          Document::Section.new(kind: kind, children: text_parts(element, depth), metadata: attributes(element, "type", "n", "rend"))
        end

        def text_parts(element, depth)
          element.children.flat_map do |child|
            next blocks_from([child], depth) unless child.element?

            case child.name
            when *PART_KINDS.keys then [matter(child, PART_KINDS.fetch(child.name))]
            when "group" then [Document::Section.new(kind: :body, children: blocks(child, depth))]
            else blocks_from([child], depth)
            end
          end
        end

        # A duplicate-page gap is folded into the page break before it.
        def add_gap(element, result)
          if element["reason"] == "duplicate" && result.last.is_a?(Document::PageBreak)
            page_break = result.pop
            metadata = page_break.metadata.with(duplicate: true, artifact: :duplicate_page)
            result << page_break.with(metadata: metadata)
          else
            result << Document::Paragraph.new(children: [@inlines.gap(element)])
          end
        end

        def attributes(element, *names)
          ["lang", *names].to_h { |name| [name.to_sym, element[name]] }.compact
        end
      end
    end
  end
end
