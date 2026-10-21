# frozen_string_literal: true

module HistoricalTextConverter
  module Document
    # A heading. Level 1 is the most significant.
    class Heading < Block
      attr_reader :level

      def self.permitted_children
        [Inline, PageBreak]
      end

      def self.separator
        ""
      end

      def initialize(level:, children: [], metadata: {})
        unless level.is_a?(Integer) && level.positive?
          raise DocumentError, "Heading level must be a positive Integer, got #{level.inspect}"
        end

        @level = level
        super(children: children, metadata: metadata)
      end

      def attributes
        super.merge(level: level)
      end
    end
  end
end
