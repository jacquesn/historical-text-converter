# frozen_string_literal: true

module HistoricalTextConverter
  module Transformations
    # The running text of one Paragraph, Line, or Heading, as the list of
    # its leaf nodes in reading order (HTC-0019), so a transformation can
    # work across the boundaries of inline elements such as Emphasis.
    #
    # A leaf is one of:
    #
    # - editable: a Text with no metadata, which transformations may change;
    # - content: a Text tagged in metadata (a gap, an expansion, a glyph),
    #   which is never edited and counts as text;
    # - a marker: anything else (a page break, a note reference, an empty
    #   span), which carries no text and is passed over.
    class RunningText
      BLOCKS = [Document::Paragraph, Document::Line, Document::Heading].freeze

      # A leaf and its path of child positions within the block.
      Leaf = Data.define(:node, :path) do
        def editable?
          node.is_a?(Document::Text) && node.metadata.empty?
        end

        def content?
          node.is_a?(Document::Text) && !node.metadata.empty?
        end
      end

      def self.block?(node)
        BLOCKS.any? { |type| node.is_a?(type) }
      end

      attr_reader :leaves

      def initialize(block)
        @block = block
        @leaves = collect(block, []).freeze
      end

      # The block with editable leaves given new values: values maps a
      # leaf's index to its new value. A leaf given "" is removed, and so
      # is an inline element left with no children.
      def replace(values)
        counter = [0]
        children = @block.children.filter_map { |child| rebuild(child, values, counter) }
        @block.with_children(children)
      end

      private

      def collect(node, path)
        return [Leaf.new(node: node, path: path.freeze)] if node.leaf? && !node.equal?(@block)

        node.children.each_with_index.flat_map { |child, index| collect(child, path + [index]) }
      end

      def rebuild(node, values, counter)
        return rebuild_leaf(node, values, counter) if node.leaf?

        children = node.children.filter_map { |child| rebuild(child, values, counter) }
        node.with_children(children) unless children.empty?
      end

      def rebuild_leaf(node, values, counter)
        index = counter[0]
        counter[0] += 1
        return node unless values.key?(index)

        values[index].empty? ? nil : node.with(value: values[index])
      end
    end
  end
end
