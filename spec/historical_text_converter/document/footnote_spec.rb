# frozen_string_literal: true

module HistoricalTextConverter
  module Document
    RSpec.describe Footnote do
      subject(:footnote) { described_class.new(label: "a", children: [Paragraph.new(children: [Text.new("Psal. 23.")])]) }

      it "records the mark used in the source" do
        expect(footnote.label).to eq("a")
      end

      it "contains blocks" do
        expect(footnote.text).to eq("Psal. 23.")
      end

      it "rejects a label that is not a String" do
        expect { described_class.new(label: 1) }.to raise_error(DocumentError, /must be a String/)
      end
    end
  end
end
