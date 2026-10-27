# frozen_string_literal: true

module HistoricalTextConverter
  module Transformations
    # Runs transformations in a fixed order (architecture §19, HTC-0019
    # T3). The order is part of the code; configuration decides only
    # which transformations run and with what settings.
    class Pipeline
      ORDER = [
        Cleanup::RemoveArtifacts,
        # Removes the blocks RemoveArtifacts leaves empty.
        Cleanup::RemoveEmptyBlocks,
        # Needs the line-end break markers, which the next step removes.
        Cleanup::RepairBrokenWords,
        Cleanup::RemoveDividerCharacters,
        Cleanup::NormalizeWhitespace
      ].freeze

      def initialize(configuration: Configuration.new)
        @configuration = configuration
      end

      # The enabled transformations, in order.
      def transformations
        context = Context.new(configuration: @configuration)
        ORDER.select { |type| context.enabled?(type.key) }.map(&:new)
      end

      # Returns the transformed Book; changes are recorded in the
      # context's change log.
      def call(book, context = Context.new(configuration: @configuration))
        transformations.reduce(book) { |result, transformation| transformation.apply(result, context) }
      end
    end
  end
end
