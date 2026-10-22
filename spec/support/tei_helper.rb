# frozen_string_literal: true

# Wraps TEI fragments (cut from real TCP texts) in a minimal document.
module TeiHelper
  def tei(body, front: "", header: "")
    <<~XML
      <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <teiHeader>#{header}</teiHeader>
        <text><front>#{front}</front><body>#{body}</body></text>
      </TEI>
    XML
  end

  def parse_tei(body, **parts)
    HistoricalTextConverter::Parsers::EEBO::Parser.new.parse_string(tei(body, **parts))
  end
end
