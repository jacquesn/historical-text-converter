# frozen_string_literal: true

module HistoricalTextConverter
  module Document
    RSpec.describe Superscript do
      it "holds raised inline text" do
        paragraph = Paragraph.new(children: [Text.new("y"), described_class.new(children: [Text.new("e")])])
        expect(paragraph.text).to eq("ye")
      end

      it "rejects block children" do
        expect { described_class.new(children: [Paragraph.new]) }.to raise_error(DocumentError)
      end
    end
  end
end
