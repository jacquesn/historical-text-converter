# frozen_string_literal: true

module HistoricalTextConverter
  module Document
    RSpec.describe PageBreak do
      it "records the source page" do
        expect(described_class.new(page: "A3v").page).to eq("A3v")
      end

      it "contributes no text" do
        expect(described_class.new.text).to eq("")
      end

      it "can appear between blocks" do
        section = Section.new(children: [Paragraph.new, described_class.new, Paragraph.new])
        expect(section.children[1]).to be_a(described_class)
      end

      it "rejects a page that is not a String" do
        expect { described_class.new(page: 12) }.to raise_error(DocumentError, /must be a String/)
      end
    end
  end
end
