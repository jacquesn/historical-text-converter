# frozen_string_literal: true

module HistoricalTextConverter
  module Parsers
    module EEBO
      RSpec.describe InlineBuilder do
        # Inline content of the first paragraph of a TEI body, cut from A13556.
        def inline(xml)
          parse_tei("<p>#{xml}</p>").body.children.first.children
        end

        def summary(xml)
          inline(xml).map { |node| [node.class.name.split("::").last, node.text] }
        end

        describe "text" do
          it "keeps printed line breaks" do
            expect(inline("in his last Sermon\nat").first.value).to eq("in his last Sermon\nat")
          end

          it "removes indentation after a newline" do
            expect(inline("that\n               the").first.value).to eq("that\nthe")
          end

          it "removes whitespace at the edges of the block" do
            expect(inline("\n   WHat Mr. \n").first.value).to eq("WHat Mr.")
          end

          it "drops the extra newline TCP adds after a page break on its own line" do
            expect(parse_tei("<p>foretold, that\n<pb/>\nthough now</p>").body.text).to eq("foretold, that\nthough now")
          end

          it "drops the extra newline TCP adds after a note on its own line" do
            expect(parse_tei("<p>sub Lege,\n   <note>N.</note>\nnot under</p>").body.children.first.text)
              .to eq("sub Lege,\nnot under")
          end
        end

        describe "italics and superscripts" do
          it "turns italics into Emphasis" do
            expect(summary("Mr. <hi>Luther</hi>\nin")).to eq([["Text", "Mr. "], ["Emphasis", "Luther"], ["Text", "\nin"]])
          end

          it "turns rend=\"sup\" into Superscript" do
            expect(summary("y<hi rend=\"sup\">e</hi>")).to eq([["Text", "y"], ["Superscript", "e"]])
          end

          it "keeps a page break inside italics" do
            expect(inline("<hi>Anti\n<pb n=\"3\"/>\nnomists</hi>").first.children.map(&:class))
              .to eq([Document::Text, Document::PageBreak, Document::Text])
          end
        end

        describe "glyphs" do
          it "renders a line-end hyphen as ∣ and joins the word into one Text" do
            expect(summary("ob<g ref=\"char:EOLhyphen\"/>served,")).to eq([["Text", "ob∣served,"]])
          end

          it "renders an unhyphenated line-end break as ¦" do
            expect(inline("Ano<g ref=\"char:EOLunhyphen\"/>mists").first.value).to eq("Ano¦mists")
          end

          it "keeps the text of other glyphs" do
            expect(inline("Cow∣per<g ref=\"char:punc\">▪</g>").first.value).to eq("Cow∣per▪")
          end
        end

        describe "gaps" do
          let(:gap) { inline("tim<gap reason=\"illegible\" extent=\"1 letter\"><desc>•</desc></gap>ly")[1] }

          it "keeps the transcribers' display form" do
            expect(gap.value).to eq("•")
          end

          it "identifies the gap without filling it" do
            expect(gap.metadata.to_h).to eq(gap: true, reason: "illegible", extent: "1 letter")
          end
        end

        describe "other inline markup" do
          it "keeps an abbreviation's expansion, marked as editorial" do
            node = inline("ali<expan><am><g ref=\"char:abque\"/></am><ex>que</ex></expan>")[1]
            expect([node.value, node.metadata.to_h]).to eq(["que", {expansion: true, abbreviation: "char:abque"}])
          end

          it "keeps a decorated initial as plain text" do
            expect(summary("<seg rend=\"decorInit\">W</seg>Hat")).to eq([["Text", "WHat"]])
          end

          it "records a page break's printed number and image" do
            expect(inline("a<pb n=\"147\" facs=\"tcp:18870:85\"/>b")[1]).to eq(
              Document::PageBreak.new(page: "147", metadata: {facs: "tcp:18870:85"})
            )
          end

          it "keeps unrecognized elements as flagged text" do
            expect(inline("<foo>odd</foo>").first.metadata[:unrecognized]).to eq("foo")
          end
        end
      end
    end
  end
end
