# frozen_string_literal: true

module HistoricalTextConverter
  module Document
    RSpec.describe Table do
      def cell(text)
        TableCell.new(children: [Paragraph.new(children: [Text.new(text)])])
      end

      let(:table) do
        described_class.new(children: [
          TableRow.new(children: [cell("l."), cell("s.")]),
          TableRow.new(children: [cell("2591"), cell("10")])
        ])
      end

      it "separates rows with newlines and cells with tabs" do
        expect(table.text).to eq("l.\ts.\n2591\t10")
      end

      it "contains only rows and page breaks" do
        expect { described_class.new(children: [cell("stray")]) }.to raise_error(DocumentError)
      end

      it "keeps rows to cells and page breaks" do
        expect { TableRow.new(children: [Paragraph.new]) }.to raise_error(DocumentError)
      end

      it "lets a cell hold several blocks" do
        expect(TableCell.new(children: [Paragraph.new, List.new]).children.size).to eq(2)
      end
    end
  end
end
