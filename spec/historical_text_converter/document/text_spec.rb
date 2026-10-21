# frozen_string_literal: true

module HistoricalTextConverter
  module Document
    RSpec.describe Text do
      subject(:text) { described_class.new("hath") }

      it "returns its value as its text" do
        expect(text.text).to eq("hath")
      end

      it "does not share the caller's string" do
        value = +"hath"
        node = described_class.new(value)
        value << "e"
        expect(node.value).to eq("hath")
      end

      it "replaces its value with #with" do
        expect(text.with(value: "has").value).to eq("has")
      end

      it "rejects a value that is not a String" do
        expect { described_class.new(:hath) }.to raise_error(DocumentError, /must be a String/)
      end

      it "cannot have children" do
        expect(described_class.permitted_children).to be_empty
      end
    end
  end
end
