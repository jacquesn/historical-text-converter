# frozen_string_literal: true

module HistoricalTextConverter
  module Transformations
    module Cleanup
      RSpec.describe RepairBrokenWords do
        let(:context) { transformation_context }

        def repaired(body_xml)
          transform(parse_tei(body_xml)).body.text
        end

        it "joins a word broken before an illegible letter" do
          # A13556-style: TCP keys the gap on the next line.
          expect(repaired("<p>in<g ref=\"char:EOLhyphen\"/>\n<gap reason=\"illegible\"><desc>•</desc></gap>itable</p>"))
            .to eq("in∣•itable")
        end

        it "joins a word broken without a printed hyphen" do
          expect(repaired("<p>to<g ref=\"char:EOLunhyphen\"/>\ngether</p>")).to eq("to¦gether")
        end

        it "joins across inline elements" do
          expect(repaired("<p><hi>in<g ref=\"char:EOLhyphen\"/></hi>\n<hi>deed</hi></p>")).to eq("in∣deed")
        end

        it "passes over a page break, leaving it in place" do
          repaired = transform(parse_tei("<p>in<g ref=\"char:EOLhyphen\"/>\n<pb n=\"5\"/>\ndeed</p>")).body.children.first
          expect(repaired.children.map { |node| node.is_a?(Document::Text) ? node.value : :page }).to eq(["in∣", :page, "deed"])
        end

        it "leaves a marker at the end of a block alone" do
          expect(repaired("<p>the end of the line<g ref=\"char:EOLhyphen\"/></p><p>next</p>"))
            .to eq("the end of the line∣\n\nnext")
        end

        it "keeps a printed hyphen, which may be a real compound" do
          # A59445: "Popish-Plot".
          expect(repaired("<p>the Popish-\nPlot</p>")).to eq("the Popish-\nPlot")
        end

        it "does not change words the transcription already keeps together" do
          expect(repaired("<p>shy<g ref=\"char:EOLhyphen\"/>neth</p>")).to eq("shy∣neth")
        end

        it "records each edited text node" do
          transform(parse_tei("<p>to<g ref=\"char:EOLunhyphen\"/>\n<hi>gether</hi></p>"), context: context)
          expect(context.change_log.changes.map { |change| [change.original, change.replacement] }).to eq([["to¦\n", "to¦"]])
        end

        it "is idempotent" do
          once = transform(parse_tei("<p>in<g ref=\"char:EOLhyphen\"/>\n<gap reason=\"illegible\"><desc>•</desc></gap>itable</p>"))
          expect(transform(once)).to eq(once)
        end
      end
    end
  end
end
