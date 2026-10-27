# frozen_string_literal: true

module HistoricalTextConverter
  module Review
    # Collects the Changes made while transforming one Book.
    class ChangeLog
      def initialize
        @changes = []
      end

      def record(change)
        @changes << change
        self
      end

      def changes
        @changes.dup.freeze
      end

      def count
        @changes.size
      end

      def by_transformation
        @changes.group_by(&:transformation)
      end
    end
  end
end
