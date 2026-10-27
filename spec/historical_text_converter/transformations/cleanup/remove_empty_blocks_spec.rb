# frozen_string_literal: true

module HistoricalTextConverter
  module Transformations
    module Cleanup
      RSpec.describe RemoveEmptyBlocks do
        let(:context) { transformation_context }

        def body(*blocks)
          transform(book(*blocks)).body.children
        end

        it "removes a paragraph with no content" do
          expect(body(paragraph, paragraph(text("Amen.")))).to eq([paragraph(text("Amen."))])
        end

        it "removes a paragraph of whitespace" do
          expect(body(paragraph(text(" \n ")))).to be_empty
        end

        it "removes a section left empty" do
          expect(body(Document::Section.new(kind: :chapter, children: [paragraph]))).to be_empty
        end

        it "keeps the Book's three parts" do
          expect(transform(book).children.size).to eq(3)
        end

        it "keeps an empty node tagged as an artifact" do
          milestone = paragraph(role: :milestone, artifact: :milestone, unit: "verse")
          expect(body(milestone)).to eq([milestone])
        end

        it "keeps a paragraph holding a page break or a gap" do
          kept = [paragraph(Document::PageBreak.new(page: "3")), paragraph(gap(""))]
          expect(body(*kept)).to eq(kept)
        end

        it "keeps an empty table cell, so the table keeps its shape" do
          table = Document::Table.new(children: [Document::TableRow.new(children: [Document::TableCell.new(children: [paragraph])])])
          expect(body(table).first.grep(Document::TableCell).size).to eq(1)
        end

        it "records each removal" do
          transform(book(paragraph(text("Amen.")), paragraph), context: context)
          expect(context.change_log.changes.map { |change| [change.rule, change.location.path] }).to eq([["empty_paragraph", [1, 1]]])
        end
      end
    end
  end
end
