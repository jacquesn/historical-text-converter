# frozen_string_literal: true

module HistoricalTextConverter
  module Document
    RSpec.describe List do
      let(:item) { ListItem.new(children: [Paragraph.new(children: [Text.new("First")])]) }

      it "is unordered by default" do
        expect(described_class.new).not_to be_ordered
      end

      it "can be ordered" do
        expect(described_class.new(ordered: true)).to be_ordered
      end

      it "contains list items" do
        expect(described_class.new(children: [item, item]).text).to eq("First\n\nFirst")
      end

      it "rejects children that are not list items" do
        expect { described_class.new(children: [Paragraph.new]) }.to raise_error(DocumentError)
      end

      it "rejects an ordered flag that is not a boolean" do
        expect { described_class.new(ordered: "yes") }.to raise_error(DocumentError, /true or false/)
      end
    end
  end
end
