# frozen_string_literal: true

module HistoricalTextConverter
  RSpec.describe ParseReport do
    subject(:report) do
      described_class.new
        .add(:unrecognized_element, "foo", "/TEI/text/body/foo")
        .add(:unknown_glyph, "char:nosuch", "/TEI/text/body/p/g")
    end

    it "starts empty" do
      expect(described_class.new).to be_empty
    end

    it "records what was met and where" do
      expect(report.entries.first.to_h).to eq(kind: :unrecognized_element, name: "foo", path: "/TEI/text/body/foo")
    end

    it "selects entries by kind" do
      expect(report.of_kind(:unknown_glyph).map(&:name)).to eq(["char:nosuch"])
    end

    it "does not let callers change its entries" do
      expect(report.entries).to be_frozen
    end
  end
end
