# frozen_string_literal: true

module HistoricalTextConverter
  module Document
    RSpec.describe Poem do
      it "contains one block per line" do
        lines = ["Line one,", "line two."].map { |line| Paragraph.new(children: [Text.new(line)]) }
        expect(described_class.new(children: lines).children.size).to eq(2)
      end

      it "rejects inline children" do
        expect { described_class.new(children: [Text.new("loose")]) }.to raise_error(DocumentError)
      end
    end
  end
end
