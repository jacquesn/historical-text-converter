# frozen_string_literal: true

module HistoricalTextConverter
  module Document
    # The root of the Document Model: a work's metadata plus its front
    # matter, body, and back matter. Front and back matter may be empty.
    class Book < Node
      attr_reader :front_matter, :body, :back_matter

      def self.permitted_children
        [Section]
      end

      def self.separator
        "\n\n"
      end

      def initialize(
        metadata: {},
        front_matter: Section.new(kind: :front_matter),
        body: Section.new(kind: :body),
        back_matter: Section.new(kind: :back_matter)
      )
        @front_matter = front_matter
        @body = body
        @back_matter = back_matter
        super(children: [front_matter, body, back_matter], metadata: metadata)
      end

      def attributes
        {metadata: metadata, front_matter: front_matter, body: body, back_matter: back_matter}
      end

      def with_children(new_children)
        front_matter, body, back_matter = new_children
        with(front_matter: front_matter, body: body, back_matter: back_matter)
      end
    end
  end
end
