# frozen_string_literal: true

module HistoricalTextConverter
  module Document
    # A run of plain text.
    class Text < Inline
      attr_reader :value

      def self.permitted_children
        []
      end

      def initialize(value, metadata: {})
        unless value.is_a?(String)
          raise DocumentError, "Text value must be a String, got #{value.class}"
        end

        @value = Document.deep_freeze(value)
        super(metadata: metadata)
      end

      def attributes
        {value: value, metadata: metadata}
      end

      def with(value: self.value, metadata: self.metadata)
        self.class.new(value, metadata: metadata)
      end

      def text
        value
      end
    end
  end
end
