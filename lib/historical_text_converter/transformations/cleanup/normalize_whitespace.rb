# frozen_string_literal: true

module HistoricalTextConverter
  module Transformations
    module Cleanup
      # Collapses each run of whitespace in running text, including
      # printed line breaks, to one space, across the boundaries of inline
      # elements, and trims the start and end of each block (HTC-0019 T4).
      # Text tagged in metadata, such as a gap's description, is kept as
      # it is and separates runs. Spacing around punctuation is not
      # changed.
      class NormalizeWhitespace < RunningTextTransformation
        private

        def edits(text, _context)
          values = {}
          after_space = true
          text.leaves.each_with_index do |leaf, index|
            if leaf.content?
              after_space = false
            elsif leaf.editable?
              value = leaf.node.value.gsub(/\s+/, " ")
              value = value.delete_prefix(" ") if after_space
              after_space = value.end_with?(" ") unless value.empty?
              values[index] = value
            end
          end
          trim_end(text, values)
        end

        def trim_end(text, values)
          text.leaves.each_with_index.reverse_each do |leaf, index|
            break if leaf.content?
            next unless leaf.editable?

            values[index] = values[index].rstrip
            break unless values[index].empty?
          end
          values
        end
      end
    end
  end
end
