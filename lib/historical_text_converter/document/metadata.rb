# frozen_string_literal: true

module HistoricalTextConverter
  module Document
    # Immutable key-value information about a node or book, such as a
    # book's title or the source page a paragraph came from.
    class Metadata
      def initialize(fields = {})
        unless fields.is_a?(Hash)
          raise DocumentError, "Metadata must be a Hash, got #{fields.class}"
        end

        @fields = Document.deep_freeze(fields.transform_keys(&:to_sym))
        freeze
      end

      def [](key)
        @fields[key.to_sym]
      end

      def fetch(key, *args, &block)
        @fields.fetch(key.to_sym, *args, &block)
      end

      def key?(key)
        @fields.key?(key.to_sym)
      end

      def empty?
        @fields.empty?
      end

      def title
        self[:title]
      end

      def author
        self[:author]
      end

      def to_h
        @fields
      end

      def with(changes)
        self.class.new(@fields.merge(changes.transform_keys(&:to_sym)))
      end

      def ==(other)
        other.instance_of?(self.class) && other.to_h == to_h
      end
      alias_method :eql?, :==

      def hash
        [self.class, @fields].hash
      end
    end
  end
end
