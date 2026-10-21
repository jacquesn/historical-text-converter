# frozen_string_literal: true

module HistoricalTextConverter
  module Document
    # An authorial or editorial note, kept separate from the paragraphs it
    # annotates. The label is the mark used in the source, such as "a" or "*".
    class Footnote < Block
      attr_reader :label

      def initialize(label: nil, children: [], metadata: {})
        unless label.nil? || label.is_a?(String)
          raise DocumentError, "Footnote label must be a String or nil, got #{label.class}"
        end

        @label = Document.deep_freeze(label)
        super(children: children, metadata: metadata)
      end

      def attributes
        super.merge(label: label)
      end
    end
  end
end
