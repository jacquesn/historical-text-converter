# frozen_string_literal: true

module HistoricalTextConverter
  # Milestone 2 acceptance criterion: a small historical document can be
  # built, traversed, and inspected entirely without HTML.
  RSpec.describe Document do
    def paragraph(*strings)
      Document::Paragraph.new(children: strings.map { |string| Document::Text.new(string) })
    end

    let(:dedication) { Document::Section.new(kind: :dedication, children: [paragraph("To the Reader.")]) }
    let(:body) do
      Document::Section.new(kind: :body, children: [
        Document::Heading.new(level: 1, children: [Document::Text.new("Chapter I.")]),
        Document::Paragraph.new(children: [
          Document::Text.new("Prayer is "), Document::Emphasis.new(children: [Document::Text.new("the lifting up")]),
          Document::Text.new(" of the heart.")
        ]),
        Document::PageBreak.new(page: "A3r"),
        Document::Quotation.new(children: [paragraph("Pray without ceasing.")]),
        Document::Footnote.new(label: "a", children: [paragraph("1 Thess. 5.17.")])
      ])
    end
    let(:book) do
      Document::Book.new(
        metadata: {title: "A Treatise of Prayer"},
        front_matter: Document::Section.new(kind: :front_matter, children: [dedication]),
        body: body
      )
    end

    it "exposes the book's metadata" do
      expect(book.metadata.title).to eq("A Treatise of Prayer")
    end

    it "finds headings by traversal" do
      expect(book.grep(Document::Heading).map(&:text)).to eq(["Chapter I."])
    end

    it "finds footnotes with the section that contains them" do
      ancestors = book.each_with_ancestors.find { |node, _| node.is_a?(Document::Footnote) }.last
      expect(ancestors.last.kind).to eq(:body)
    end

    it "produces the book's text without any markup" do
      expect(book.body.text).to eq("Chapter I.\n\nPrayer is the lifting up of the heart.\n\n" \
                                   "Pray without ceasing.\n\n1 Thess. 5.17.")
    end

    it "includes front matter in the book's text" do
      expect(book.text).to start_with("To the Reader.\n\nChapter I.")
    end

    it "does not depend on Nokogiri" do
      source = Dir[File.expand_path("../../lib/historical_text_converter/document{,/*}.rb", __dir__)]
      expect(source.map { |path| File.read(path) }.join).not_to match(/nokogiri/i)
    end
  end
end
