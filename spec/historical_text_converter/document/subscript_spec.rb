# frozen_string_literal: true

module HistoricalTextConverter
  module Document
    RSpec.describe Subscript do
      it "holds lowered inline text" do
        expect(Paragraph.new(children: [Text.new("H"), described_class.new(children: [Text.new("2")])]).text).to eq("H2")
      end

      it "rejects block children" do
        expect { described_class.new(children: [Paragraph.new]) }.to raise_error(DocumentError)
      end
    end
  end
end
