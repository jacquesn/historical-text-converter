# frozen_string_literal: true

module HistoricalTextConverter
  module Document
    RSpec.describe Poem do
      let(:lines) { ["Line one,", "line two."].map { |line| Line.new(children: [Text.new(line)]) } }

      it "contains lines" do
        expect(described_class.new(children: lines).children.size).to eq(2)
      end

      it "contains nested poems as stanzas" do
        expect(described_class.new(children: [described_class.new(children: lines)]).text).to eq("Line one,\n\nline two.")
      end

      it "rejects inline children" do
        expect { described_class.new(children: [Text.new("loose")]) }.to raise_error(DocumentError)
      end
    end
  end
end
