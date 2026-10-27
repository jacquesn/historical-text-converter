# frozen_string_literal: true

module HistoricalTextConverter
  module Transformations
    module Cleanup
      # Joins a word broken at a line end when the transcription leaves
      # whitespace after the break marker, as in "in∣" + newline +
      # "•…itable" (HTC-0019 T4). It removes that whitespace when more text
      # follows in the same block, passing over page breaks and note
      # references, which stay in place.
      #
      # The markers ("∣", "¦") are the only evidence of the break, so this
      # must run before RemoveDividerCharacters. It never joins across
      # blocks and never joins at a printed hyphen ("-"), which may be a
      # real compound.
      class RepairBrokenWords < RunningTextTransformation
        private

        # joins holds the removals of whitespace after a marker, applied
        # only once text follows; it is nil when no marker is pending.
        def edits(text, context)
          marker = Regexp.union(setting(context, "markers"))
          values = {}
          joins = nil
          text.leaves.each_with_index do |leaf, index|
            next unless leaf.content? || leaf.editable?

            value = leaf.editable? ? leaf.node.value : ""
            if joins
              rest = value.lstrip
              if leaf.editable? && rest.empty?
                joins[index] = ""
                next
              end
              values.merge!(joins)
              value = rest
            end
            joins = nil
            next unless leaf.editable?

            values[index] = value.gsub(/(#{marker})\s+(?=\S)/, '\1')
            joins = trailing_join(values[index], marker, index)
          end
          values
        end

        # The pending removal after a marker at the end of value: {} when
        # the marker ends it, {index => value without the whitespace} when
        # whitespace follows the marker, or nil when no marker ends it.
        def trailing_join(value, marker, index)
          return {} if value.match?(/#{marker}\z/)
          return unless value.match?(/#{marker}\s+\z/)

          {index => value.rstrip}
        end
      end
    end
  end
end
