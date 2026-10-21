# frozen_string_literal: true

module HistoricalTextConverter
  module Document
    # An ordered or unordered list of ListItems.
    class List < Block
      attr_reader :ordered

      def self.permitted_children
        [ListItem, PageBreak]
      end

      def initialize(ordered: false, children: [], metadata: {})
        unless [true, false].include?(ordered)
          raise DocumentError, "List ordered must be true or false, got #{ordered.inspect}"
        end

        @ordered = ordered
        super(children: children, metadata: metadata)
      end

      def ordered?
        ordered
      end

      def attributes
        super.merge(ordered: ordered)
      end
    end
  end
end
