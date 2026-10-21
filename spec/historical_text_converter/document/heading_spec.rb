# frozen_string_literal: true

module HistoricalTextConverter
  module Document
    RSpec.describe Heading do
      subject(:heading) { described_class.new(level: 2, children: [Text.new("Chapter "), Text.new("II.")]) }

      it "records its level" do
        expect(heading.level).to eq(2)
      end

      it "joins its inline content" do
        expect(heading.text).to eq("Chapter II.")
      end

      it "includes its level in equality" do
        expect(heading).not_to eq(heading.with(level: 1))
      end

      it "rejects a level below 1" do
        expect { described_class.new(level: 0) }.to raise_error(DocumentError, /positive Integer/)
      end

      it "rejects block children" do
        expect { described_class.new(level: 1, children: [Paragraph.new]) }.to raise_error(DocumentError)
      end
    end
  end
end
