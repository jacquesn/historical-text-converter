# frozen_string_literal: true

module HistoricalTextConverter
  module Document
    RSpec.describe Quotation do
      it "contains paragraphs" do
        lines = %w[first second].map { |line| Paragraph.new(children: [Text.new(line)]) }
        expect(described_class.new(children: lines).text).to eq("first\n\nsecond")
      end

      it "rejects inline children" do
        expect { described_class.new(children: [Text.new("loose")]) }.to raise_error(DocumentError)
      end
    end
  end
end
