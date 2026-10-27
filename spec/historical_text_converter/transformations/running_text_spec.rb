# frozen_string_literal: true

module HistoricalTextConverter
  module Transformations
    RSpec.describe RunningText do
      subject(:running_text) do
        described_class.new(paragraph(text("a "), Document::Emphasis.new(children: [text(" ")]), Document::PageBreak.new(page: "2"), gap("•")))
      end

      it "lists the leaves of a block in reading order, with their paths" do
        expect(running_text.leaves.map(&:path)).to eq([[0], [1, 0], [2], [3]])
      end

      it "sorts leaves into editable text, tagged content, and markers" do
        expect(running_text.leaves.map { |leaf| [leaf.editable?, leaf.content?] })
          .to eq([[true, false], [true, false], [false, false], [false, true]])
      end

      it "replaces editable leaves" do
        expect(running_text.replace(0 => "b ").text).to eq("b  •")
      end

      it "removes a leaf given an empty value, and an inline element it empties" do
        expect(running_text.replace(1 => "").children.map(&:class)).to eq([Document::Text, Document::PageBreak, Document::Text])
      end

      it "treats paragraphs, lines, and headings as running text" do
        expect([paragraph, Document::Line.new, Document::Heading.new(level: 1), Document::Section.new].map { |node| described_class.block?(node) })
          .to eq([true, true, true, false])
      end
    end
  end
end
