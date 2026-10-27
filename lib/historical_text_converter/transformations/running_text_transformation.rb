# frozen_string_literal: true

module HistoricalTextConverter
  module Transformations
    # Base class for transformations that edit running text. A subclass
    # implements #edits(running_text, context), returning a Hash from leaf
    # index to new value for the editable leaves it changes; this class
    # applies the edits and records one change per edited leaf.
    class RunningTextTransformation < Transformation
      def apply(book, context)
        rewrite(book) do |node, location|
          next node unless RunningText.block?(node)

          text = RunningText.new(node)
          values = edits(text, context).reject { |index, value| text.leaves[index].node.value == value }
          next node if values.empty?

          record_edits(context, text, location, values)
          text.replace(values)
        end
      end

      private

      def edits(running_text, context)
        raise NotImplementedError, "#{self.class.name} must implement #edits"
      end

      def record_edits(context, text, location, values)
        page = location.page
        text.leaves.each_with_index do |leaf, index|
          page = leaf.node.page || page if leaf.node.is_a?(Document::PageBreak)
          next unless values.key?(index)

          leaf_location = Review::Location.new(path: location.path + leaf.path, page: page)
          record(context, leaf_location, original: leaf.node.value, replacement: values[index])
        end
      end
    end
  end
end
