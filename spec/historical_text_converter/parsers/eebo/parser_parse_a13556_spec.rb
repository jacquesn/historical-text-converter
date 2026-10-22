# frozen_string_literal: true

# Milestone 3 acceptance: the full EEBO-TCP text of A13556 (Thomas Taylor,
# Regula vitae, 1631) parses into a Book with nothing lost.
module HistoricalTextConverter
  module Parsers
    module EEBO
      RSpec.describe Parser, "#parse" do
        context "with A13556" do
          fixture = File.expand_path("../../../fixtures/eebo/A13556.xml", __dir__)
          book = described_class.new.parse(fixture)

          # Words of the TEI <text> as transcribed. Duplicate-page placeholders
          # are dropped (the parser folds them into page breaks); gaps and
          # abbreviations are reduced to their text without the XML formatting
          # inside them; then notes are separated from the words around them
          # (the parser moves them after their paragraph).
          source_words = lambda do
            tei = Nokogiri::XML(File.read(fixture))
            tei.remove_namespaces!
            tei.xpath("//text//gap[@reason='duplicate']").each(&:remove)
            as_text = ->(node, string) { node.replace(Nokogiri::XML::Text.new(string, tei)) }
            tei.xpath("//text//gap").each { |gap| as_text.call(gap, gap.xpath("desc").text.strip) }
            tei.xpath("//text//expan").each { |expan| as_text.call(expan, expan.xpath("ex").text) }
            tei.xpath("//text//note").each { |note| as_text.call(note, " #{note.text} ") }
            tei.at_xpath("//text").text.split.tally
          end

          def nodes(book, type)
            book.grep(Document.const_get(type))
          end

          it "has the title page and preface as front matter" do
            expect(book.front_matter.children.map(&:kind)).to eq([:title_page, :preface])
          end

          it "has twelve chapters" do
            expect(book.body.children.map(&:kind)).to eq([:chapter] * 12)
          end

          it "keeps all 328 paragraphs of the source" do
            paragraphs = book.each_with_ancestors.count do |node, ancestors|
              node.is_a?(Document::Paragraph) && node.metadata.empty? && ancestors.none?(Document::Footnote)
            end
            expect(paragraphs).to eq(328)
          end

          it "keeps all 284 page breaks" do
            expect(nodes(book, :PageBreak).size).to eq(284)
          end

          it "marks the 26 duplicate pages" do
            expect(nodes(book, :PageBreak).count { |page| page.metadata[:duplicate] }).to eq(26)
          end

          it "keeps the printed page numbering, errors included" do
            expect(nodes(book, :PageBreak).filter_map(&:page).each_cons(2)).to include(["145", "147"], ["147", "147"])
          end

          it "pairs 222 notes with 222 references" do
            references = nodes(book, :NoteReference).map(&:target)
            expect(nodes(book, :Footnote).map { |note| note.metadata[:id] }).to eq(references).and have_attributes(size: 222)
          end

          it "keeps the 199 illegible and foreign-text gaps unfilled" do
            expect(nodes(book, :Text).count { |text| text.metadata[:gap] }).to eq(199)
          end

          it "recognizes every element in the source" do
            expect(book.count { |node| node.metadata[:unrecognized] }).to eq(0)
          end

          it "keeps every word of the source" do
            expect(book.text.delete("∣¦").split.tally).to eq(source_words.call)
          end

          it "reads the title from the header" do
            expect(book.metadata.title).to start_with("Regula vitæ the rule of the law vnder the Gospel.")
          end
        end
      end
    end
  end
end
