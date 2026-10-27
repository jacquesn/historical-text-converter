# frozen_string_literal: true

module HistoricalTextConverter
  module Review
    RSpec.describe Location do
      subject(:location) { described_class.new(path: [1, 0], page: "12") }

      it "locates a child of the node" do
        expect(location.child(3)).to eq(described_class.new(path: [1, 0, 3], page: "12"))
      end

      it "leaves the page out when there is none" do
        expect(described_class.new(path: []).page).to be_nil
      end

      it "cannot be changed" do
        expect(location.path).to be_frozen
      end
    end
  end
end
