# frozen_string_literal: true

module HistoricalTextConverter
  module Parsers
    module EEBO
      # Builds block Document nodes from TEI <front>, <body>, and <back>.
      class BlockBuilder
        def initialize
          @inlines = InlineBuilder.new
        end

        def matter(element, kind)
          return Document::Section.new(kind: kind) unless element

          Document::Section.new(kind: kind, children: blocks(element, 0))
        end

        private

        # depth is the number of enclosing <div>s, which sets heading levels.
        def blocks(element, depth)
          element.children.each_with_object([]) { |node, result| add_block(node, depth, result) }
        end

        def add_block(node, depth, result)
          return if node.text? && node.content.strip.empty?
          return result << unrecognized(node, "text") if node.text?
          return unless node.element?

          case node.name
          when "div" then result << division(node, depth + 1)
          when "head" then result.concat(heading(node, depth))
          when "p" then result.concat(paragraph(node))
          when "argument" then result << Document::Section.new(kind: :argument, children: blocks(node, depth))
          when "q" then result << Document::Quotation.new(children: blocks(node, depth))
          when "bibl" then result.concat(paragraph(node, role: :citation))
          when "trailer" then result.concat(paragraph(node, role: :trailer))
          when "pb" then result << @inlines.page_break(node)
          when "gap" then add_gap(node, result)
          else result << unrecognized(node, node.name)
          end
        end

        def division(element, depth)
          Document::Section.new(
            kind: element["type"]&.to_sym,
            children: blocks(element, depth),
            metadata: {n: element["n"]}.compact
          )
        end

        def heading(element, depth)
          with_notes(element) { |children| Document::Heading.new(level: [depth, 1].max, children: children) }
        end

        def paragraph(element, **metadata)
          with_notes(element) { |children| Document::Paragraph.new(children: children, metadata: metadata) }
        end

        # Each note follows the block that contains its reference (HTC-0016).
        def with_notes(element)
          children, notes = @inlines.build(element)
          [yield(children), *notes.map { |id, note| footnote(id, note) }]
        end

        def footnote(id, element)
          children = element.at_xpath("p") ? blocks(element, 0) : paragraph(element)
          Document::Footnote.new(children: children, metadata: {id: id, place: element["place"]}.compact)
        end

        # A duplicate-page gap is folded into the page break before it.
        def add_gap(element, result)
          if element["reason"] == "duplicate" && result.last.is_a?(Document::PageBreak)
            page_break = result.pop
            result << page_break.with(metadata: page_break.metadata.with(duplicate: true))
          else
            result << Document::Paragraph.new(children: [@inlines.gap(element)])
          end
        end

        # Unknown material is kept as text and flagged, never dropped.
        def unrecognized(node, name)
          text = @inlines.clean(node.content).strip
          children = text.empty? ? [] : [Document::Text.new(text)]
          Document::Paragraph.new(children: children, metadata: {unrecognized: name})
        end
      end
    end
  end
end
