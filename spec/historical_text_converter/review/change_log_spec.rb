# frozen_string_literal: true

module HistoricalTextConverter
  module Review
    RSpec.describe ChangeLog do
      subject(:log) { described_class.new.record(change("RemoveArtifacts")).record(change("NormalizeWhitespace")).record(change("RemoveArtifacts")) }

      def change(transformation)
        Change.new(transformation: transformation, original: "a", replacement: "", location: Location.new(path: [1]))
      end

      it "counts its changes" do
        expect(log.count).to eq(3)
      end

      it "groups changes by transformation" do
        expect(log.by_transformation.transform_values(&:size)).to eq("RemoveArtifacts" => 2, "NormalizeWhitespace" => 1)
      end

      it "keeps changes in the order they were recorded" do
        expect(log.changes.map(&:transformation)).to eq(%w[RemoveArtifacts NormalizeWhitespace RemoveArtifacts])
      end

      it "does not let callers change its changes" do
        expect(log.changes).to be_frozen
      end
    end
  end
end
