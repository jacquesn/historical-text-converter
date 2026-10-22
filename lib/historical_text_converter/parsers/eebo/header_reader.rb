# frozen_string_literal: true

module HistoricalTextConverter
  module Parsers
    module EEBO
      # Reads bibliographic metadata from a TEI <teiHeader>.
      class HeaderReader
        FIELDS = {
          title: "fileDesc/titleStmt/title",
          author: "fileDesc/titleStmt/author",
          publisher: "fileDesc/sourceDesc/biblFull/publicationStmt/publisher",
          pub_place: "fileDesc/sourceDesc/biblFull/publicationStmt/pubPlace",
          date: "fileDesc/sourceDesc/biblFull/publicationStmt/date",
          availability: "fileDesc/publicationStmt/availability"
        }.freeze

        def initialize(header)
          @header = header
        end

        def metadata
          return Document::Metadata.new unless @header

          fields = FIELDS.transform_values { |path| value(path) }
          Document::Metadata.new(fields.merge(idno: identifiers).compact)
        end

        private

        # Header values are catalogue data, not the author's text, so their
        # XML formatting whitespace is collapsed.
        def value(path)
          node = @header.at_xpath(path)
          node&.text&.gsub(/\s+/, " ")&.strip
        end

        def identifiers
          ids = @header.xpath("fileDesc/publicationStmt/idno")
            .group_by { |idno| idno["type"].to_s }
            .transform_values { |idnos| idnos.map { |idno| idno.text.strip } }

          ids.empty? ? nil : ids
        end
      end
    end
  end
end
