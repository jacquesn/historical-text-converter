# frozen_string_literal: true

require_relative "parse_report"

module HistoricalTextConverter
  # Common interface for all parsers. A parser reads a source document and
  # returns a Document::Book; it never modernizes or corrects the text.
  class Parser
    def parse(path)
      parse_string(read(path))
    end

    # Returns [book, report]; see ParseReport.
    def parse_with_report(path)
      parse_string_with_report(read(path))
    end

    def parse_string(_source)
      raise NotImplementedError, "#{self.class.name} must implement #parse_string"
    end

    def parse_string_with_report(source)
      [parse_string(source), ParseReport.new]
    end

    private

    def read(path)
      File.read(path, encoding: "UTF-8")
    rescue SystemCallError => e
      raise ParseError, "Cannot read source file: #{path}: #{e.message}"
    end
  end
end
