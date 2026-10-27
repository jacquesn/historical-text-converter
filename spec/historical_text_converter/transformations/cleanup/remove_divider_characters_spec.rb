# frozen_string_literal: true

module HistoricalTextConverter
  module Transformations
    module Cleanup
      RSpec.describe RemoveDividerCharacters do
        let(:context) { transformation_context }

        it "joins the halves of a word" do
          expect(transform(book(paragraph(text("the∣book")))).body.text).to eq("thebook")
        end

        it "removes the marker for a break without a hyphen" do
          expect(transform(book(paragraph(text("to¦gether")))).body.text).to eq("together")
        end

        it "keeps hyphens and other characters" do
          expect(transform(book(paragraph(text("Popish-Plot | ¶ ſ")))).body.text).to eq("Popish-Plot | ¶ ſ")
        end

        it "removes a text node left empty" do
          expect(transform(book(paragraph(text("in"), text("∣")))).body.children.first.children).to eq([text("in")])
        end

        it "does not change text tagged in metadata" do
          expect(transform(book(paragraph(gap("〈∣〉")))).body.text).to eq("〈∣〉")
        end

        it "removes only the characters configured" do
          settings = {"remove_divider_characters" => {"characters" => ["¦"]}}
          expect(transform(book(paragraph(text("shy∣neth to¦gether"))), settings).body.text).to eq("shy∣neth together")
        end

        it "records each change with its location" do
          transform(book(paragraph(text("shy∣neth"))), context: context)
          expect(context.change_log.changes.map { |change| [change.replacement, change.location.path] }).to eq([["shyneth", [1, 0, 0]]])
        end
      end
    end
  end
end
