# frozen_string_literal: true

module HistoricalTextConverter
  module Document
    # Base class for block elements. By default a block contains other
    # blocks; blocks that hold running text override this to contain
    # inline elements instead.
    class Block < Node
      def self.permitted_children
        [Block, PageBreak]
      end

      def self.separator
        "\n\n"
      end
    end
  end
end
