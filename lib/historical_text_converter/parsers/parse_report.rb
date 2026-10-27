# frozen_string_literal: true

module HistoricalTextConverter
  # What a parser met that needs a person's attention (HTC-0018 D12): for
  # example, elements it did not recognize. The material itself is still
  # kept in the Book.
  class ParseReport
    Entry = Struct.new(:kind, :name, :path)

    def initialize
      @entries = []
    end

    # kind is a Symbol such as :unrecognized_element; name identifies what
    # was met; path locates it in the source.
    def add(kind, name, path)
      @entries << Entry.new(kind, name, path).freeze
      self
    end

    def entries
      @entries.dup.freeze
    end

    def of_kind(kind)
      @entries.select { |entry| entry.kind == kind }
    end

    def empty?
      @entries.empty?
    end
  end
end
