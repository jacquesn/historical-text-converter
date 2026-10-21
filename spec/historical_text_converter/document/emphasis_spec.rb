# frozen_string_literal: true

module HistoricalTextConverter
  module Document
    RSpec.describe Emphasis do
      it "holds formatted text semantically rather than as markup" do
        emphasis = described_class.new(children: [Text.new("important")])
        expect(emphasis.text).to eq("important")
      end

      it "can be nested inside other inline content" do
        inner = described_class.new(children: [Text.new("very")])
        expect(described_class.new(children: [inner, Text.new(" much")]).text).to eq("very much")
      end

      it "rejects block children" do
        expect { described_class.new(children: [Paragraph.new]) }.to raise_error(DocumentError)
      end
    end
  end
end
