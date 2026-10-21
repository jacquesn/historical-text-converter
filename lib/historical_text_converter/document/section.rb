# frozen_string_literal: true

module HistoricalTextConverter
  module Document
    # A grouping of blocks, such as a chapter, a preface, or a book's body.
    # The optional kind names the role the section plays.
    class Section < Block
      attr_reader :kind

      def initialize(kind: nil, children: [], metadata: {})
        unless kind.nil? || kind.is_a?(Symbol)
          raise DocumentError, "Section kind must be a Symbol or nil, got #{kind.class}"
        end

        @kind = kind
        super(children: children, metadata: metadata)
      end

      def attributes
        super.merge(kind: kind)
      end
    end
  end
end
