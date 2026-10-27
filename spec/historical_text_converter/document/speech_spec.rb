# frozen_string_literal: true

module HistoricalTextConverter
  module Document
    RSpec.describe Speech do
      it "holds the speaker and what is spoken" do
        speech = described_class.new(children: [
          Paragraph.new(children: [Text.new("Pyr.")], metadata: {role: :speaker}),
          Line.new(children: [Text.new("BEliev't my Lords, they say the Prince does Wonders.")])
        ])
        expect(speech.text).to start_with("Pyr.\n\nBEliev't")
      end

      it "rejects inline children" do
        expect { described_class.new(children: [Text.new("loose")]) }.to raise_error(DocumentError)
      end
    end
  end
end
