# frozen_string_literal: true

module HistoricalTextConverter
  module Document
    # Inline content marked for its meaning rather than its formatting, such
    # as a quotation, citation, or date. The role names what it marks
    # (HTC-0018 D7).
    class Span < Inline
      attr_reader :role

      def initialize(role:, children: [], metadata: {})
        unless role.is_a?(Symbol)
          raise DocumentError, "Span role must be a Symbol, got #{role.inspect}"
        end

        @role = role
        super(children: children, metadata: metadata)
      end

      def attributes
        super.merge(role: role)
      end
    end
  end
end
