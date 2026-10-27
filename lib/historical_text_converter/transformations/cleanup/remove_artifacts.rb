# frozen_string_literal: true

module HistoricalTextConverter
  module Transformations
    module Cleanup
      # Removes source artifacts of the kinds listed in configuration
      # (HTC-0019 T4), selected by their artifact: metadata (HTC-0018 D11).
      # Artifacts that stand for text or mark uncertainty, such as gaps and
      # expansions, are kept by default.
      class RemoveArtifacts < Transformation
        def apply(book, context)
          kinds = setting(context, "kinds").map(&:to_sym)
          rewrite(book) do |node, location|
            kind = node.metadata[:artifact]
            next node unless kinds.include?(kind)

            record(context, location, original: node.text, replacement: "", rule: kind.to_s)
            nil
          end
        end
      end
    end
  end
end
