# frozen_string_literal: true

module HistoricalTextConverter
  module Document
    # Base class for every element of the Document Model.
    #
    # Nodes are immutable: #with and #rewrite build modified copies and
    # leave the original untouched. Unchanged subtrees are shared between
    # copies, so a node does not store its parent; #each_with_ancestors
    # reports where each node sits in a tree.
    class Node
      include Enumerable

      attr_reader :children, :metadata

      # Node classes this node may contain.
      def self.permitted_children
        []
      end

      # String placed between the text of adjacent children.
      def self.separator
        ""
      end

      def initialize(children: [], metadata: {})
        @children = Document.deep_freeze(validate_children(children))
        @metadata = metadata.is_a?(Metadata) ? metadata : Metadata.new(metadata)
        freeze
      end

      def attributes
        {children: children, metadata: metadata}
      end

      def with(**changes)
        self.class.new(**attributes.merge(changes))
      end

      def with_children(new_children)
        with(children: new_children)
      end

      def leaf?
        children.empty?
      end

      def text
        children.map(&:text).reject(&:empty?).join(self.class.separator)
      end

      # Visits this node and every descendant, depth-first.
      def each
        return enum_for(:each) unless block_given?

        each_with_ancestors { |node, _ancestors| yield node }
      end

      # Visits this node and every descendant, depth-first, with the
      # ancestors of each node from the root down.
      def each_with_ancestors(&block)
        return enum_for(:each_with_ancestors) unless block

        walk([].freeze, &block)
        self
      end

      # Builds a new tree bottom-up. The block receives each node (with its
      # children already rewritten) and returns the node to use in its
      # place. Subtrees the block leaves unchanged are reused, not copied.
      def rewrite(&block)
        rewritten = children.map { |child| child.rewrite(&block) }
        unchanged = rewritten.zip(children).all? { |new_child, old_child| new_child.equal?(old_child) }

        block.call(unchanged ? self : with_children(rewritten))
      end

      def ==(other)
        other.instance_of?(self.class) && other.attributes == attributes
      end
      alias_method :eql?, :==

      def hash
        [self.class, attributes].hash
      end

      protected

      def walk(ancestors, &block)
        block.call(self, ancestors)

        path = (ancestors + [self]).freeze
        children.each { |child| child.walk(path, &block) }
      end

      private

      def validate_children(children)
        unless children.is_a?(Array)
          raise DocumentError, "#{self.class.name} children must be an Array, got #{children.class}"
        end

        children.each do |child|
          next if self.class.permitted_children.any? { |type| child.is_a?(type) }

          raise DocumentError, "#{self.class.name} cannot contain #{child.class.name}"
        end
      end
    end
  end
end
