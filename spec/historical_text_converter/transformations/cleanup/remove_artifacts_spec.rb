# frozen_string_literal: true

module HistoricalTextConverter
  module Transformations
    module Cleanup
      RSpec.describe RemoveArtifacts do
        let(:context) { transformation_context }

        # A19568: a milestone inside running text; a gap kept for review.
        let(:source) do
          parse_tei('<p>the <milestone unit="verse" n="3"/>Lord <gap reason="illegible"><desc>〈◊〉</desc></gap> saith</p>' \
            '<pb n="4" facs="tcp:1:8"/><gap reason="duplicate"><desc>〈1 page duplicate〉</desc></gap>')
        end

        it "removes the artifact kinds listed in configuration" do
          expect(transform(source).body.grep(Document::Node).map { |node| node.metadata[:artifact] }.compact).to eq([:gap])
        end

        it "keeps the text around a removed artifact" do
          expect(transform(source).body.text).to eq("the Lord 〈◊〉 saith")
        end

        it "removes only the kinds configured" do
          settings = {"remove_artifacts" => {"kinds" => ["gap"]}}
          expect(transform(source, settings).body.text).to eq("the Lord  saith")
        end

        it "records each removal with its kind and location" do
          transform(source, context: context)
          expect(context.change_log.changes.map { |change| [change.rule, change.location.path] })
            .to eq([["milestone", [1, 0, 1]], ["duplicate_page", [1, 1]]])
        end

        it "is idempotent" do
          once = transform(source)
          expect(transform(once)).to eq(once)
        end
      end
    end
  end
end
