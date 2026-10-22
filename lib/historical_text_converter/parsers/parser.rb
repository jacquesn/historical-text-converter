# frozen_string_literal: true

module HistoricalTextConverter
  # Common interface for all parsers. A parser reads a source document and
  # returns a Document::Book; it never modernizes or corrects the text.
  class Parser
    def parse(path)
      parse_string(File.read(path, encoding: "UTF-8"))
    rescue SystemCallError => e
      raise ParseError, "Cannot read source file: #{path}: #{e.message}"
    end

    def parse_string(_source)
      raise NotImplementedError, "#{self.class.name} must implement #parse_string"
    end
  end
end
