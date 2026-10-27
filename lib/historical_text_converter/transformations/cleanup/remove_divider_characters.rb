# frozen_string_literal: true

module HistoricalTextConverter
  module Transformations
    module Cleanup
      # Deletes the line-end break markers ("∣", "¦") listed in
      # configuration (architecture §21). Text tagged in metadata, such as
      # a gap's description, is not touched.
      class RemoveDividerCharacters < Transformation
        def apply(book, context)
          characters = setting(context, "characters").join
          rewrite(book) do |node, location|
            next node unless node.is_a?(Document::Text) && node.metadata.empty? && node.value.count(characters).positive?

            value = node.value.delete(characters)
            record(context, location, original: node.value, replacement: value)
            node.with(value: value) unless value.empty?
          end
        end
      end
    end
  end
end
