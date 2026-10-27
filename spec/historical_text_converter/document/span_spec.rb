# frozen_string_literal: true

module HistoricalTextConverter
  module Document
    RSpec.describe Span do
      subject(:span) { described_class.new(role: :date, children: [Text.new("October the 1st. 1686.")]) }

      it "records what it marks" do
        expect(span.role).to eq(:date)
      end

      it "holds inline content" do
        expect(span.text).to eq("October the 1st. 1686.")
      end

      it "may be empty, as a marker" do
        expect(described_class.new(role: :milestone)).to be_leaf
      end

      it "includes its role in equality" do
        expect(span).not_to eq(span.with(role: :citation))
      end

      it "rejects a role that is not a Symbol" do
        expect { described_class.new(role: "date") }.to raise_error(DocumentError, /must be a Symbol/)
      end
    end
  end
end
