# frozen_string_literal: true

module HistoricalTextConverter
  module Parsers
    module EEBO
      RSpec.describe GlyphTable do
        subject(:table) { described_class.default }

        it "loads the whole TCP character table" do
          expect(table.size).to eq(1624)
        end

        it "returns a glyph's display form" do
          expect(table.display("char:abrum")).to eq("ꝝ")
        end

        it "agrees with the line-end break glyphs chosen in HTC-0015" do
          expect(%w[char:EOLhyphen char:EOLunhyphen].map { |ref| table.display(ref) }).to eq(%w[∣ ¦])
        end

        it "returns nil for a glyph it does not define" do
          expect(table.display("char:nosuch")).to be_nil
        end
      end
    end
  end
end
