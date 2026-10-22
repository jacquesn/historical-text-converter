# frozen_string_literal: true

module HistoricalTextConverter
  module Parsers
    module EEBO
      RSpec.describe Parser do
        def kinds(section)
          section.children.map { |child| child.is_a?(Document::Section) ? child.kind : child.class }
        end

        describe "loading" do
          it "raises ParseError for malformed XML" do
            expect { described_class.new.parse_string("<TEI><text>") }.to raise_error(ParseError, /Malformed XML/)
          end

          it "raises ParseError when there is no body" do
            expect { described_class.new.parse_string("<TEI><text/></TEI>") }.to raise_error(ParseError, /<body>/)
          end

          it "does not resolve external entities" do
            xml = %(<!DOCTYPE TEI [<!ENTITY xxe SYSTEM "file:///etc/hosts">]><TEI><text><body><p>&xxe;</p></body></text></TEI>)
            expect(described_class.new.parse_string(xml).text).not_to include("localhost")
          end

          it "accepts TEI without the TEI namespace" do
            expect(described_class.new.parse_string("<TEI><text><body><p>Text</p></body></text></TEI>").text).to eq("Text")
          end
        end

        describe "front matter, body, and back matter" do
          let(:book) do
            parse_tei('<div type="chapter" n="1"><head>CHAP. 1.</head></div>',
              front: '<div type="title_page"><p>Regula Vitae,</p></div><div type="preface"/>')
          end

          it "maps <front> divisions to front-matter sections by type" do
            expect(kinds(book.front_matter)).to eq([:title_page, :preface])
          end

          it "maps <body> divisions to body sections, keeping n" do
            expect(book.body.children.first.metadata[:n]).to eq("1")
          end

          it "leaves back matter empty when there is no <back>" do
            expect(book.back_matter.children).to be_empty
          end
        end

        describe "headings" do
          let(:chapter) do
            parse_tei('<div type="chapter"><head>CHAP. 4.</head><div type="error"><head>1 ERROR.</head></div></div>')
              .body.children.first
          end

          it "sets a chapter heading to level 1" do
            expect(chapter.children.first.level).to eq(1)
          end

          it "sets a heading's level from its division's depth" do
            expect(chapter.children.last.children.first.level).to eq(2)
          end
        end

        describe "blocks" do
          let(:division) do
            parse_tei(<<~XML).body.children.first
              <div type="chapter">
                <argument><p>Containing the ground of the following discourse.</p></argument>
                <q><bibl>Numb. 12. 8.</bibl><p>Wherefore were ye not afraid</p></q>
                <trailer>FINIS.</trailer>
              </div>
            XML
          end

          it "maps argument, q, and trailer" do
            expect(kinds(division)).to eq([:argument, Document::Quotation, Document::Paragraph])
          end

          it "tags a quotation's citation" do
            expect(division.children[1].children.first.metadata[:role]).to eq(:citation)
          end

          it "tags a trailer" do
            expect(division.children.last.metadata[:role]).to eq(:trailer)
          end

          it "keeps unrecognized block elements as flagged paragraphs" do
            expect(parse_tei("<lg><l>A line</l></lg>").body.children.first.metadata[:unrecognized]).to eq("lg")
          end
        end

        describe "notes" do
          let(:body) { parse_tei('<p>us,<note place="margin">Calv.</note> nor<note place="margin">Iudg.</note></p>').body }

          it "places a reference where the note was anchored" do
            expect(body.children.first.children.map(&:class))
              .to eq([Document::Text, Document::NoteReference, Document::Text, Document::NoteReference])
          end

          it "places each note after the paragraph that refers to it" do
            expect(body.children.drop(1).map(&:text)).to eq(["Calv.", "Iudg."])
          end

          it "links each reference to its note" do
            targets = body.children.first.grep(Document::NoteReference).map(&:target)
            expect(body.children.drop(1).map { |note| note.metadata[:id] }).to eq(targets)
          end

          it "records the note's placement" do
            expect(body.children[1].metadata[:place]).to eq("margin")
          end
        end

        describe "page breaks" do
          let(:pages) do
            parse_tei(<<~XML).body.children
              <pb facs="tcp:18870:141" n="42"/>
              <gap reason="duplicate" extent="1 page"><desc>〈1 page duplicate〉</desc></gap>
              <pb facs="tcp:18870:142" n="43"/>
            XML
          end

          it "folds a duplicate-page gap into the page break before it" do
            expect(pages.map { |page| page.metadata[:duplicate] }).to eq([true, nil])
          end

          it "keeps unnumbered page breaks without a page label" do
            expect(parse_tei("<pb facs=\"tcp:1:1\"/>").body.children.first.page).to be_nil
          end

          it "marks transcriber-added page images" do
            pb = parse_tei('<pb facs="tcp:1:1" rendition="simple:additions"/>').body.children.first
            expect(pb.metadata[:additions]).to be(true)
          end
        end
      end
    end
  end
end
