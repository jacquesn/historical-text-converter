# frozen_string_literal: true

module HistoricalTextConverter
  module Document
    RSpec.describe Section do
      it "records the role it plays" do
        expect(described_class.new(kind: :preface).kind).to eq(:preface)
      end

      it "may omit its kind" do
        expect(described_class.new.kind).to be_nil
      end

      it "contains nested sections" do
        chapter = described_class.new(kind: :chapter, children: [Paragraph.new(children: [Text.new("Text")])])
        expect(described_class.new(children: [chapter]).text).to eq("Text")
      end

      it "rejects inline children" do
        expect { described_class.new(children: [Text.new("loose")]) }.to raise_error(DocumentError)
      end

      it "rejects a kind that is not a Symbol" do
        expect { described_class.new(kind: "preface") }.to raise_error(DocumentError, /must be a Symbol/)
      end
    end
  end
end
