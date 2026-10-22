# frozen_string_literal: true

module HistoricalTextConverter
  module Document
    # The point in running text where a note is anchored. The note itself
    # is a Footnote whose metadata id equals this reference's target.
    class NoteReference < Inline
      attr_reader :target

      def self.permitted_children
        []
      end

      def initialize(target:, metadata: {})
        unless target.is_a?(String) && !target.empty?
          raise DocumentError, "NoteReference target must be a non-empty String, got #{target.inspect}"
        end

        @target = Document.deep_freeze(target)
        super(metadata: metadata)
      end

      def attributes
        {target: target, metadata: metadata}
      end
    end
  end
end
