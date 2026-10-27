# frozen_string_literal: true

module HistoricalTextConverter
  module Document
    RSpec.describe Line do
      it "holds a verse line's inline content" do
        line = described_class.new(children: [Text.new("Since God hath fyxt our "), Emphasis.new(children: [Text.new("dayes")])])
        expect(line.text).to eq("Since God hath fyxt our dayes")
      end

      it "rejects block children" do
        expect { described_class.new(children: [Paragraph.new]) }.to raise_error(DocumentError)
      end
    end
  end
end
