# frozen_string_literal: true

module HistoricalTextConverter
  module Document
    # A table of TableRows (HTC-0018 D5).
    class Table < Block
      def self.permitted_children
        [TableRow, PageBreak]
      end

      def self.separator
        "\n"
      end
    end
  end
end
