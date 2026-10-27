# frozen_string_literal: true

module HistoricalTextConverter
  module Transformations
    RSpec.describe Pipeline do
      # A13556-style running text: a milestone, a line-end break before a
      # gap, and printed line breaks.
      let(:source) do
        parse_tei("<p><milestone unit=\"verse\" n=\"1\"/>the in<g ref=\"char:EOLhyphen\"/>\n" \
          "<gap reason=\"illegible\"><desc>•</desc></gap>itable shy<g ref=\"char:EOLhyphen\"/>neth\nof <hi>God</hi></p>")
      end

      def configuration(settings)
        instance_double(Configuration, transformations: Configuration.new.transformations.merge(settings))
      end

      it "runs the cleanup transformations in their fixed order" do
        expect(described_class.new.transformations.map(&:name))
          .to eq(%w[RemoveArtifacts RemoveEmptyBlocks RepairBrokenWords RemoveDividerCharacters NormalizeWhitespace])
      end

      it "skips a transformation disabled in configuration" do
        pipeline = described_class.new(configuration: configuration("remove_empty_blocks" => {"enabled" => false}))
        expect(pipeline.transformations.map(&:name)).not_to include("RemoveEmptyBlocks")
      end

      it "turns parsed text into clean running text" do
        expect(described_class.new.call(source).body.text).to eq("the in•itable shyneth of God")
      end

      it "gives the same result every time" do
        first, second = Array.new(2) { described_class.new.call(source) }
        expect(first).to eq(second)
      end

      it "is idempotent" do
        once = described_class.new.call(source)
        expect(described_class.new.call(once)).to eq(once)
      end

      it "records the changes of each transformation in the context" do
        context = Context.new
        described_class.new.call(source, context)
        expect(context.change_log.by_transformation.keys)
          .to eq(%w[RemoveArtifacts RepairBrokenWords RemoveDividerCharacters NormalizeWhitespace])
      end

      it "leaves the original Book unchanged" do
        expect { described_class.new.call(source) }.not_to(change { source.body.text })
      end
    end
  end
end
