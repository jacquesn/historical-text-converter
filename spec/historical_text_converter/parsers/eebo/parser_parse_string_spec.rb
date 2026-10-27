# frozen_string_literal: true

# Milestone 4 decisions (HTC-0018), each checked on snippets cut from the
# fixtures in spec/fixtures/eebo.
module HistoricalTextConverter
  module Parsers
    module EEBO
      RSpec.describe Parser, "#parse_string" do
        def first_block(body)
          parse_tei(body).body.children.first
        end

        def classes(nodes)
          nodes.map { |node| node.class.name.split("::").last }
        end

        describe "D1: volumes and embedded texts" do
          # A19568: a group volume of separately printed texts.
          let(:book) do
            parser = described_class.new
            parser.parse_string(<<~XML)
              <TEI><text>
                <front><div type="title_page"><p>THE YOVNG-MANS Warning-peece</p></div></front>
                <group>
                  <text><front><div type="title_page"><p>A Sermon</p></div></front><body><p>Text one</p></body></text>
                  <text><body><p>Text two</p></body></text>
                </group>
              </text></TEI>
            XML
          end

          it "builds the body from the group's texts" do
            expect(book.body.children.map(&:kind)).to eq([:text, :text])
          end

          it "keeps each text's own front matter and body" do
            expect(book.body.children.first.children.map(&:kind)).to eq([:front_matter, :body])
          end

          it "keeps the volume's own front matter" do
            expect(book.front_matter.text).to eq("THE YOVNG-MANS Warning-peece")
          end

          it "builds a floatingText as a section of its type, with its own parts" do
            # A95820
            section = first_block('<floatingText type="letter" xml:lang="unk"><body><p>Resolved</p></body></floatingText>')
            expect([section.kind, section.children.map(&:kind), section.metadata[:lang]]).to eq([:letter, [:body], "unk"])
          end
        end

        describe "D2: verse" do
          # A10388
          let(:poem) do
            first_block(<<~XML)
              <lg type="poem"><head>A Dittie</head>
                <l><seg rend="decorInit">S</seg>Ince God hath fyxt our dayes and yeares,<note place="margin">Sira. 17.</note> to liue</l>
                <l n="2">And takes his choice of vs his ſheepe,</l>
                <lg><l>A stanza line</l></lg>
              </lg>
            XML
          end

          it "builds lg as a Poem of Lines, nested Poems, and headings" do
            expect(classes(poem.children)).to eq(%w[Heading Line Footnote Line Poem])
          end

          it "keeps the poem's type and a line's number" do
            expect([poem.metadata[:type], poem.children[3].metadata[:n]]).to eq(["poem", "2"])
          end

          it "keeps a line's text and places its note after it" do
            expect(poem.children[1..2].map(&:text)).to eq(["SInce God hath fyxt our dayes and yeares, to liue", "Sira. 17."])
          end

          it "allows a line outside a poem" do
            expect(first_block("<l>A line</l>")).to be_a(Document::Line)
          end
        end

        describe "D3: letters and document parts" do
          # A54309
          let(:division) do
            first_block(<<~XML)
              <div type="letter">
                <opener><salute>Great Sir,</salute></opener>
                <closer>
                  <signed><hi>Your Grace's moſt Humble Servant,</hi> James Percy.</signed>
                  <dateline><date>October <hi>the</hi> 1ſt. <hi>1686.</hi></date></dateline>
                </closer>
                <postscript><p>P.S.</p></postscript>
              </div>
            XML
          end

          it "builds openers, closers, and postscripts as sections" do
            expect(division.children.map(&:kind)).to eq([:opener, :closer, :postscript])
          end

          it "tags salutes, signatures, and datelines" do
            expect(division.children[0..1].flat_map(&:children).map { |p| p.metadata[:role] }).to eq([:salute, :signed, :dateline])
          end

          it "marks a date inside a dateline" do
            expect(division.children[1].children.last.children.first.role).to eq(:date)
          end

          it "wraps loose text in a closer in a paragraph" do
            expect(first_block("<closer>FINIS.</closer>").children.first).to be_a(Document::Paragraph)
          end
        end

        describe "D4: lists" do
          let(:list_blocks) do
            parse_tei(<<~XML).body.children
              <list type="syllogism"><head>Of the Errors</head>
                <label>1.</label><item>Containing the ground <list><item>nested</item></list></item>
                <item>Second</item>
              </list>
            XML
          end

          it "puts the list's heading before the list" do
            expect(classes(list_blocks)).to eq(%w[Heading List])
          end

          it "joins a label to the item it precedes" do
            item = list_blocks.last.children.first
            expect(item.children.map { |child| child.metadata[:role] }).to eq([:label, nil, nil])
          end

          it "wraps an item's text in a paragraph and keeps nested lists" do
            expect(classes(list_blocks.last.children.first.children)).to eq(%w[Paragraph Paragraph List])
          end

          it "keeps the list's type" do
            expect(list_blocks.last.metadata[:type]).to eq("syllogism")
          end
        end

        describe "D5: tables" do
          # A95820
          let(:table) do
            first_block(<<~XML)
              <table><row role="label"><cell> </cell><cell>l.</cell></row>
                <row><cell>Due from the Exciſe, and lent the Lord <hi>Inchiqueen</hi></cell><cell cols="2">2591</cell></row>
              </table>
            XML
          end

          it "builds rows of cells" do
            expect(table.children.map { |row| classes(row.children) }).to eq([%w[TableCell TableCell]] * 2)
          end

          it "wraps a cell's text in a paragraph" do
            expect(table.children.last.children.first.children.first.text).to eq("Due from the Exciſe, and lent the Lord Inchiqueen")
          end

          it "keeps row and cell attributes" do
            expect([table.children.first.metadata[:role], table.children.last.children.last.metadata[:cols]]).to eq(["label", "2"])
          end
        end

        describe "D6: figures" do
          # A32628
          let(:figure) do
            first_block("<figure><p>DIEV ET MON DROIT</p><figDesc>royal blazon or coat of arms</figDesc></figure>")
          end

          it "keeps the text printed with the image" do
            expect(figure.children.first.text).to eq("DIEV ET MON DROIT")
          end

          it "marks the transcribers' description as an artifact" do
            expect(figure.children.last.metadata.to_h).to eq(role: :description, artifact: :description)
          end
        end

        describe "D8: drama" do
          # A59445
          let(:division) do
            first_block(<<~XML)
              <div type="act"><stage><hi>Enter</hi> Pyrrhus, Endymion, Neander.</stage>
                <sp><speaker>Pyr.</speaker><l>BEliev't my Lords, they say the Prince does Wonders.</l></sp>
              </div>
            XML
          end

          it "builds a speech of its speaker and lines" do
            expect(classes(division.children.last.children)).to eq(%w[Paragraph Line])
          end

          it "tags the speaker" do
            expect(division.children.last.children.first.metadata[:role]).to eq(:speaker)
          end

          it "tags a stage direction between blocks" do
            expect(division.children.first.metadata[:role]).to eq(:stage_direction)
          end
        end

        describe "D9: blocks inside running text" do
          let(:blocks) { parse_tei("<p>Cast up thus,<list><item>15</item></list>which makes 135.</p>").body.children }

          it "splits the paragraph around the block, in order" do
            expect(classes(blocks)).to eq(%w[Paragraph List Paragraph])
          end

          it "tags the text after the block as continued" do
            expect(blocks.map { |block| block.metadata[:continued] }).to eq([nil, nil, true])
          end

          it "builds a quotation holding verse as a block" do
            quotation = parse_tei("<p>as the Poet: <q><l>Vita scelesta vale</l></q> said</p>").body.children[1]
            expect(classes(quotation.children)).to eq(%w[Line])
          end

          it "splits a heading around a figure" do
            heads = parse_tei("<div><head>By the King.<figure><p>C R</p></figure>A Proclamation</head></div>").body.children.first.children
            expect(classes(heads)).to eq(%w[Heading Figure Heading])
          end
        end

        describe "D10: markers" do
          it "keeps a milestone between blocks as an empty, tagged paragraph" do
            paragraph = first_block('<milestone unit="year" n="753"/><p>Text</p>')
            expect(paragraph.metadata.to_h).to eq(role: :milestone, artifact: :milestone, unit: "year", n: "753")
          end

          it "keeps a page break that opens running text inside the paragraph" do
            # A13556: <note><gap/>.</note>
            expect(first_block("<pb n=\"3\"/>though now").children.map(&:class)).to eq([Document::PageBreak, Document::Text])
          end
        end

        describe "D13: documented but unobserved elements" do
          it "builds forme work as an artifact paragraph" do
            expect(first_block("<fw>Regula Vitae.</fw>").metadata.to_h).to eq(role: :forme_work, artifact: :forme_work)
          end

          it "builds ab as a paragraph" do
            expect(first_block("<ab>Text</ab>")).to be_a(Document::Paragraph)
          end

          it "keeps language attributes" do
            expect(first_block('<div xml:lang="lat"><p>Qui</p></div>').metadata[:lang]).to eq("lat")
          end
        end
      end
    end
  end
end
