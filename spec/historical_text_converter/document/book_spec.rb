# frozen_string_literal: true

module HistoricalTextConverter
  module Document
    RSpec.describe Book do
      let(:body) { Section.new(kind: :body, children: [Paragraph.new(children: [Text.new("Body text")])]) }
      let(:book) { described_class.new(metadata: {title: "A Treatise"}, body: body) }

      it "accepts metadata as a Hash" do
        expect(book.metadata.title).to eq("A Treatise")
      end

      it "defaults to empty front and back matter" do
        expect([book.front_matter, book.back_matter].map(&:kind)).to eq([:front_matter, :back_matter])
      end

      it "orders its children front matter, body, back matter" do
        expect(book.children).to eq([book.front_matter, body, book.back_matter])
      end

      it "skips empty sections in its text" do
        expect(book.text).to eq("Body text")
      end

      it "rebuilds itself when rewritten" do
        rewritten = book.rewrite { |node| (node == Text.new("Body text")) ? node.with(value: "New text") : node }
        expect(rewritten.body.text).to eq("New text")
      end

      it "rejects a body that is not a Section" do
        expect { described_class.new(body: Paragraph.new) }.to raise_error(DocumentError)
      end
    end
  end
end
