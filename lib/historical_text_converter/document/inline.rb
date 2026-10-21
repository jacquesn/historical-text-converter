# frozen_string_literal: true

module HistoricalTextConverter
  module Document
    # Base class for inline elements: running text and its formatting.
    class Inline < Node
      def self.permitted_children
        [Inline, PageBreak]
      end
    end
  end
end
