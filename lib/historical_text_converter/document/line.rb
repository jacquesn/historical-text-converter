# frozen_string_literal: true

module HistoricalTextConverter
  module Document
    # A line of verse (HTC-0018 D2).
    class Line < Block
      def self.permitted_children
        [Inline, PageBreak]
      end

      def self.separator
        ""
      end
    end
  end
end
