# frozen_string_literal: true

module HistoricalTextConverter
  module Document
    # A row of TableCells (HTC-0018 D5).
    class TableRow < Block
      def self.permitted_children
        [TableCell, PageBreak]
      end

      def self.separator
        "\t"
      end
    end
  end
end
