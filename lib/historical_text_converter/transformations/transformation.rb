# frozen_string_literal: true

module HistoricalTextConverter
  module Transformations
    # Base class for transformations (architecture §17, HTC-0019 T1).
    #
    # #apply receives a Book and a Context and returns a new Book; nodes
    # are immutable, so the original is unchanged. Applying a
    # transformation twice gives the same Book as applying it once. Every
    # change is recorded in the context's change log.
    class Transformation
      # The key of this transformation's settings, such as
      # "remove_artifacts".
      def self.key
        name.split("::").last.gsub(/(?<=[a-z])(?=[A-Z])/, "_").downcase
      end

      # The stable name recorded with each change.
      def name
        self.class.name.split("::").last
      end

      def key
        self.class.key
      end

      def apply(book, context)
        raise NotImplementedError, "#{self.class.name} must implement #apply"
      end

      private

      def settings(context)
        context.settings(key)
      end

      def setting(context, name)
        settings(context).fetch(name) do
          raise ConfigurationError, "Missing setting: transformations.#{key}.#{name}"
        end
      end

      def record(context, location, original:, replacement:, rule: nil)
        context.change_log.record(
          Review::Change.new(transformation: name, original: original, replacement: replacement, location: location, rule: rule)
        )
      end

      # Builds a new Book bottom-up, as Node#rewrite does, passing the
      # block each node (its children already rewritten) and its
      # Location. The block returns the node to use in its place, or nil
      # to remove it. Unchanged subtrees are reused.
      def rewrite(book, &block)
        visit(book, Review::Location.new(path: []), {page: nil}, &block)
      end

      def visit(node, location, state, &block)
        location = location.with(page: state[:page])
        state[:page] = node.page || state[:page] if node.is_a?(Document::PageBreak)
        children = node.children.each_with_index.filter_map do |child, index|
          visit(child, location.child(index), state, &block)
        end
        unchanged = children.size == node.children.size && children.zip(node.children).all? { |new, old| new.equal?(old) }

        block.call(unchanged ? node : node.with_children(children), location)
      end
    end
  end
end
