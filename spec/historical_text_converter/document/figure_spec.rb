# frozen_string_literal: true

module HistoricalTextConverter
  module Document
    RSpec.describe Figure do
      it "holds the text printed with an image and its description" do
        figure = described_class.new(children: [
          Paragraph.new(children: [Text.new("DIEV ET MON DROIT")]),
          Paragraph.new(children: [Text.new("royal blazon or coat of arms")], metadata: {role: :description})
        ])
        expect(figure.children.last.metadata[:role]).to eq(:description)
      end

      it "rejects inline children" do
        expect { described_class.new(children: [Text.new("loose")]) }.to raise_error(DocumentError)
      end
    end
  end
end
