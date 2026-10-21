# frozen_string_literal: true

module HistoricalTextConverter
  module Document
    # A paragraph of running text.
    class Paragraph < Block
      def self.permitted_children
        [Inline, PageBreak]
      end

      def self.separator
        ""
      end
    end
  end
end
