# frozen_string_literal: true

module HistoricalTextConverter
  module Document
    RSpec.describe ListItem do
      it "contains a nested list" do
        nested = List.new(children: [described_class.new(children: [Paragraph.new(children: [Text.new("inner")])])])
        expect(described_class.new(children: [nested]).text).to eq("inner")
      end

      it "rejects inline children" do
        expect { described_class.new(children: [Text.new("loose")]) }.to raise_error(DocumentError)
      end
    end
  end
end
