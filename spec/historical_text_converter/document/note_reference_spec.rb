# frozen_string_literal: true

module HistoricalTextConverter
  module Document
    RSpec.describe NoteReference do
      subject(:reference) { described_class.new(target: "note-1") }

      it "records the note it points to" do
        expect(reference.target).to eq("note-1")
      end

      it "contributes no text" do
        expect(Paragraph.new(children: [Text.new("us,"), reference]).text).to eq("us,")
      end

      it "rejects an empty target" do
        expect { described_class.new(target: "") }.to raise_error(DocumentError, /non-empty String/)
      end
    end
  end
end
