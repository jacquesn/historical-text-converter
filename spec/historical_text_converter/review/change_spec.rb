# frozen_string_literal: true

module HistoricalTextConverter
  module Review
    RSpec.describe Change do
      subject(:change) do
        described_class.new(transformation: "RemoveDividerCharacters", original: "shy∣neth", replacement: "shyneth",
          location: Location.new(path: [1, 0, 0]))
      end

      it "records what changed" do
        expect(change.to_h.slice(:transformation, :original, :replacement))
          .to eq(transformation: "RemoveDividerCharacters", original: "shy∣neth", replacement: "shyneth")
      end

      it "has no rule unless one is given" do
        expect(change.rule).to be_nil
      end
    end
  end
end
