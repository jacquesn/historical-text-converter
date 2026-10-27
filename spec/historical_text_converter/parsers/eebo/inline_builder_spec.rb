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

          it "gives an empty glyph its display form from the TCP character table" do
            expect(inline("<g ref=\"char:abquam\"/>").first.value).to eq("ꝗ")
          end

          it "tags a glyph that took its display form from the table" do
            expect(inline("<g ref=\"char:abquam\"/>").first.metadata.to_h).to eq(artifact: :glyph, glyph: "char:abquam")
          end

          it "keeps an empty glyph the table lacks as flagged, not dropped" do
            expect(inline("<g ref=\"char:nosuch\"/>").first.metadata.to_h).to eq(glyph: "char:nosuch", unrecognized: "g")
          end
        end

        describe "gaps" do
          let(:gap) { inline("tim<gap reason=\"illegible\" extent=\"1 letter\"><desc>•</desc></gap>ly")[1] }

          it "keeps the transcribers' display form" do
            expect(gap.value).to eq("•")
          end

          it "identifies the gap without filling it" do
            expect(gap.metadata.to_h).to eq(artifact: :gap, gap: true, reason: "illegible", extent: "1 letter")
          end
        end

        describe "D7: inline wrappers" do
          it "marks an inline quotation" do
            # A28515: [<q>Understand in the Liberty</q>
            expect(summary("[<q>Understand in the <hi>Liberty,</hi></q>")).to eq([["Text", "["], ["Span", "Understand in the Liberty,"]])
          end

          it "names what each inline wrapper marks" do
            roles = inline("<bibl>Rom. 6.</bibl><date>1686</date><stage>Aside.</stage><unclear>x</unclear>").map(&:role)
            expect(roles).to eq([:citation, :date, :stage_direction, :unclear])
          end

          it "keeps an abbreviation's expansion from a choice, with the abbreviation as printed" do
            # A67916: 15<choice><abbr>q</abbr><expan>quartern</expan></choice>
            node = inline("15<choice>\n  <abbr>q</abbr>\n  <expan>quartern</expan>\n</choice>")[1]
            expect([node.value, node.metadata[:abbreviation]]).to eq(["quartern", "q"])
          end

          it "keeps a reading as printed, with its correction" do
            span = inline("<choice><sic>teh</sic><corr>the</corr></choice>").first
            expect([span.role, span.text, span.metadata[:correction]]).to eq([:sic, "teh", "the"])
          end

          it "turns rend=\"sub\" into Subscript" do
            expect(summary("H<hi rend=\"sub\">2</hi>")).to eq([["Text", "H"], ["Subscript", "2"]])
          end

          it "marks supplied text as an artifact" do
            expect(inline("<supplied>the</supplied>").first.metadata[:artifact]).to eq(:supplied)
          end
        end

        describe "D10 and D11: markers and artifacts" do
          it "keeps a transcribers' line break as a newline" do
            expect(inline("Regula<lb/>Vitae").first.value).to eq("Regula\nVitae")
          end

          it "keeps a milestone as an empty, tagged span" do
            expect(inline("a<milestone unit=\"year\" n=\"753\"/>b")[1].metadata.to_h).to eq(artifact: :milestone, unit: "year", n: "753")
          end

          it "folds a duplicate-page gap inside running text into its page break" do
            # A02926: <p><pb/><gap reason="duplicate">...</gap></p>
            page = inline("a<pb facs=\"tcp:1:75\"/>\n<gap reason=\"duplicate\"><desc>〈1 page duplicate〉</desc></gap>")[1]
            expect(page.metadata.to_h).to eq(facs: "tcp:1:75", duplicate: true, artifact: :duplicate_page)
          end

          it "marks transcriber-added page images as artifacts" do
            expect(inline("a<pb rendition=\"simple:additions\"/>")[1].metadata[:artifact]).to eq(:transcriber_addition)
          end
        end

        describe "D12: parse report" do
          def report(xml)
            Parser.new.parse_string_with_report(tei("<p>#{xml}</p>")).last
          end

          it "reports unrecognized elements with their path" do
            expect(report("<foo>odd</foo>").entries.map(&:to_h)).to eq([{kind: :unrecognized_element, name: "foo", path: "/TEI/text/body/p/foo"}])
          end

          it "reports glyphs the TCP table lacks" do
            expect(report("<g ref=\"char:nosuch\"/>").of_kind(:unknown_glyph).map(&:name)).to eq(["char:nosuch"])
          end

          it "reports documented elements not seen in the survey" do
            expect(report("<del>gone</del>").of_kind(:documented_element).map(&:name)).to eq(["del"])
          end

          it "is empty for recognized markup" do
            expect(report("Mr. <hi>Luther</hi>")).to be_empty
          end
        end

        describe "other inline markup" do
          it "keeps an abbreviation's expansion, marked as editorial" do
            node = inline("ali<expan><am><g ref=\"char:abque\"/></am><ex>que</ex></expan>")[1]
            expect([node.value, node.metadata.to_h]).to eq(["que", {artifact: :expansion, expansion: true, abbreviation: "char:abque"}])
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
