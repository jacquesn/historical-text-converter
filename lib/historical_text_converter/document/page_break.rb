# frozen_string_literal: true

module HistoricalTextConverter
  module Document
    # The boundary between two pages of the source. Page breaks fall both
    # between blocks and in the middle of running text, so a PageBreak may
    # appear in either.
    class PageBreak < Node
      attr_reader :page

      def initialize(page: nil, metadata: {})
        unless page.nil? || page.is_a?(String)
          raise DocumentError, "PageBreak page must be a String or nil, got #{page.class}"
        end

        @page = Document.deep_freeze(page)
        super(metadata: metadata)
      end

      def attributes
        {page: page, metadata: metadata}
      end
    end
  end
end
