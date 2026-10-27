# frozen_string_literal: true

module HistoricalTextConverter
  module Transformations
    module Cleanup
      # Removes paragraphs, lines, headings, and sections with no content,
      # such as those left by RemoveArtifacts, which must run first
      # (HTC-0019 T4).
      #
      # The Book's three parts are never removed, nor is a node tagged
      # artifact: (whether to remove artifacts is RemoveArtifacts' choice).
      # Empty table cells are kept, so a table keeps its shape.
      class RemoveEmptyBlocks < Transformation
        def apply(book, context)
          rewrite(book) do |node, location|
            next node if location.path.size <= 1 || !empty?(node)

            record(context, location, original: node.text, replacement: "", rule: rule(node))
            nil
          end
        end

        private

        def empty?(node)
          return false if node.metadata.key?(:artifact)
          return node.children.empty? if node.is_a?(Document::Section)
          return false unless RunningText.block?(node)

          node.children.all? { |child| child.is_a?(Document::Text) && child.metadata.empty? && child.value.strip.empty? }
        end

        def rule(node)
          "empty_#{node.class.name.split("::").last.downcase}"
        end
      end
    end
  end
end
