# frozen_string_literal: true

module HistoricalTextConverter
  module Document
    RSpec.describe Paragraph do
      it "contains inline content" do
        paragraph = described_class.new(children: [Text.new("Thou "), Emphasis.new(children: [Text.new("art")])])
        expect(paragraph.text).to eq("Thou art")
      end

      it "contains a page break in the middle of its text" do
        paragraph = described_class.new(children: [Text.new("a"), PageBreak.new(page: "B1r"), Text.new("b")])
        expect(paragraph.text).to eq("ab")
      end

      it "rejects block children" do
        expect { described_class.new(children: [Quotation.new]) }.to raise_error(DocumentError)
      end
    end
  end
end
