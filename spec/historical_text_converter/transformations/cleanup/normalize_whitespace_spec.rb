# frozen_string_literal: true

module HistoricalTextConverter
  module Transformations
    module Cleanup
      RSpec.describe NormalizeWhitespace do
        let(:context) { transformation_context }

        def normalized(*children)
          transform(book(paragraph(*children))).body.children.first
        end

        it "collapses repeated spaces" do
          expect(normalized(text("in  his   last")).text).to eq("in his last")
        end

        it "turns printed line breaks into spaces" do
          expect(normalized(text("in his last Sermon\nat")).text).to eq("in his last Sermon at")
        end

        it "trims the edges of a block" do
          expect(normalized(text(" \nWHat Mr. \t")).text).to eq("WHat Mr.")
        end

        it "collapses whitespace across inline elements" do
          expect(normalized(text("Mr. \n"), Document::Emphasis.new(children: [text(" Luther")])).text).to eq("Mr. Luther")
        end

        it "collapses whitespace across a page break" do
          expect(normalized(text("that \n"), Document::PageBreak.new(page: "2"), text("\nthough")).text).to eq("that though")
        end

        it "does not change a gap's description" do
          expect(normalized(text("a \n"), gap("〈 in non-Latin alphabet 〉"), text(" b")).text).to eq("a 〈 in non-Latin alphabet 〉 b")
        end

        it "keeps space before punctuation as transcribed" do
          expect(normalized(gap("〈◊〉"), text(" ; and")).text).to eq("〈◊〉 ; and")
        end

        it "removes a text node left empty" do
          expect(normalized(text("Amen. "), text("\n")).children).to eq([text("Amen.")])
        end

        it "keeps paragraphs apart" do
          expect(transform(book(paragraph(text("one \n")), paragraph(text("\ntwo")))).body.text).to eq("one\n\ntwo")
        end

        it "records each edited text node with the page it is on" do
          transform(book(Document::PageBreak.new(page: "7"), paragraph(text("a\nb"))), context: context)
          expect(context.change_log.changes.map { |change| [change.replacement, change.location.to_h] })
            .to eq([["a b", {path: [1, 1, 0], page: "7"}]])
        end

        it "is idempotent" do
          once = transform(parse_tei("<p>foretold, that\n<pb/>\nthough <hi>now</hi>\n</p>"))
          expect(transform(once)).to eq(once)
        end
      end
    end
  end
end
