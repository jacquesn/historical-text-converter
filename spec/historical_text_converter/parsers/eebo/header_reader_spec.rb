# frozen_string_literal: true

module HistoricalTextConverter
  module Parsers
    module EEBO
      RSpec.describe HeaderReader do
        # Abridged from the A13556 teiHeader.
        let(:header) do
          <<~XML
            <fileDesc>
              <titleStmt><title>Regula vitæ the rule of the law
                vnder the Gospel.</title><author>Taylor, Thomas, 1576-1632.</author></titleStmt>
              <publicationStmt>
                <idno type="DLPS">A13556</idno><idno type="STC">STC 23851</idno><idno type="STC">ESTC S118279</idno>
                <availability><p>This Phase I text is available for reuse.</p></availability>
              </publicationStmt>
              <sourceDesc><biblFull><publicationStmt>
                <publisher>By W[illiam] I[ones] for Robert Dawlman,</publisher>
                <pubPlace>Imprinted at London :</pubPlace><date>1631.</date>
              </publicationStmt></biblFull></sourceDesc>
            </fileDesc>
          XML
        end
        let(:metadata) { parse_tei("<p/>", header: header).metadata }

        it "reads the title, collapsing XML formatting whitespace" do
          expect(metadata.title).to eq("Regula vitæ the rule of the law vnder the Gospel.")
        end

        it "reads the author" do
          expect(metadata.author).to eq("Taylor, Thomas, 1576-1632.")
        end

        it "reads the original publication details" do
          expect(metadata.to_h.values_at(:publisher, :pub_place, :date))
            .to eq(["By W[illiam] I[ones] for Robert Dawlman,", "Imprinted at London :", "1631."])
        end

        it "groups identifiers by type" do
          expect(metadata[:idno]).to eq("DLPS" => ["A13556"], "STC" => ["STC 23851", "ESTC S118279"])
        end

        it "reads the availability statement" do
          expect(metadata[:availability]).to eq("This Phase I text is available for reuse.")
        end

        it "omits fields the header lacks" do
          expect(parse_tei("<p/>", header: "<fileDesc/>").metadata).to be_empty
        end
      end
    end
  end
end
