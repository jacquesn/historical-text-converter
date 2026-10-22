# frozen_string_literal: true

require "nokogiri"
require_relative "header_reader"
require_relative "inline_builder"
require_relative "block_builder"

module HistoricalTextConverter
  module Parsers
    module EEBO
      # Parses EEBO-TCP TEI XML into a Book (HTC-0015, HTC-0016).
      class Parser < HistoricalTextConverter::Parser
        def parse_string(source)
          tei = load(source)
          text = tei.at_xpath("/TEI/text") || raise(ParseError, "No TEI <text> element found")
          body = text.at_xpath("body") || raise(ParseError, "No TEI <body> element found")
          blocks = BlockBuilder.new

          Document::Book.new(
            metadata: HeaderReader.new(tei.at_xpath("/TEI/teiHeader")).metadata,
            front_matter: blocks.matter(text.at_xpath("front"), :front_matter),
            body: blocks.matter(body, :body),
            back_matter: blocks.matter(text.at_xpath("back"), :back_matter)
          )
        end

        private

        # Strict parsing: malformed XML is an error, never silently repaired.
        # External entities are not substituted and the network is not used.
        def load(source)
          document = Nokogiri::XML(source) { |config| config.strict.nonet }
          document.remove_namespaces!
          document
        rescue Nokogiri::XML::SyntaxError => e
          raise ParseError, "Malformed XML: #{e.message}"
        end
      end
    end
  end
end
