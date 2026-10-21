# frozen_string_literal: true

module HistoricalTextConverter
  module Document
    RSpec.describe Metadata do
      subject(:metadata) { described_class.new(title: "A Treatise", source: {collection: "EEBO"}) }

      it "supports string and symbol keys" do
        expect(metadata["title"]).to eq(metadata[:title])
      end

      it "exposes the title" do
        expect(metadata.title).to eq("A Treatise")
      end

      it "returns nil for an absent author" do
        expect(metadata.author).to be_nil
      end

      it "freezes nested values" do
        expect(metadata[:source][:collection]).to be_frozen
      end

      it "does not share the caller's values" do
        title = +"A Treatise"
        copy = described_class.new(title: title)
        title << " of Prayer"
        expect(copy.title).to eq("A Treatise")
      end

      it "merges changes into a copy with #with" do
        expect(metadata.with(author: "Anonymous").to_h.keys).to eq([:title, :source, :author])
      end

      it "is equal to metadata with the same fields" do
        expect(metadata).to eq(described_class.new("title" => "A Treatise", "source" => {collection: "EEBO"}))
      end

      it "rejects anything but a Hash" do
        expect { described_class.new("A Treatise") }.to raise_error(DocumentError, /must be a Hash/)
      end
    end
  end
end
