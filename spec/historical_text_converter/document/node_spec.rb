# frozen_string_literal: true

module HistoricalTextConverter
  module Document
    RSpec.describe Node do
      let(:greeting) { Text.new("Hail, ") }
      let(:honorific) { Emphasis.new(children: [Text.new("Sir")]) }
      let(:paragraph) { Paragraph.new(children: [greeting, honorific], metadata: {page: "A2r"}) }
      let(:section) { Section.new(children: [Heading.new(level: 1, children: [Text.new("To the Reader")]), paragraph]) }

      describe "construction" do
        it "freezes the node" do
          expect(paragraph).to be_frozen
        end

        it "freezes its children" do
          expect(paragraph.children).to be_frozen
        end

        it "does not share the caller's children array" do
          children = [greeting]
          node = Paragraph.new(children: children)
          children << honorific
          expect(node.children).to eq([greeting])
        end

        it "wraps metadata" do
          expect(paragraph.metadata[:page]).to eq("A2r")
        end

        it "rejects children of the wrong kind" do
          expect { Paragraph.new(children: [paragraph]) }
            .to raise_error(DocumentError, "HistoricalTextConverter::Document::Paragraph cannot contain " \
                                           "HistoricalTextConverter::Document::Paragraph")
        end

        it "rejects children that are not an Array" do
          expect { Paragraph.new(children: greeting) }.to raise_error(DocumentError, /must be an Array/)
        end

        it "is a leaf when it has no children" do
          expect(greeting).to be_leaf
        end
      end

      describe "#text" do
        it "joins inline content directly" do
          expect(paragraph.text).to eq("Hail, Sir")
        end

        it "separates blocks with a blank line" do
          expect(section.text).to eq("To the Reader\n\nHail, Sir")
        end
      end

      describe "traversal" do
        let(:sir) { honorific.children.first }

        it "visits every node depth-first" do
          expect(section.map(&:class)).to eq([Section, Heading, Text, Paragraph, Text, Emphasis, Text])
        end

        it "reports each node's ancestors from the root down" do
          _node, ancestors = section.each_with_ancestors.find { |node, _| node.equal?(sir) }
          expect(ancestors).to eq([section, paragraph, honorific])
        end

        it "gives the root no ancestors" do
          expect(section.each_with_ancestors.first).to eq([section, []])
        end
      end

      describe "equality" do
        it "treats nodes with the same class and attributes as equal" do
          original = Text.new("thou")
          expect(original).to eq(Text.new("thou"))
        end

        it "can be used as a hash key" do
          expect([Text.new("thou"), Text.new("thou")].uniq.size).to eq(1)
        end

        it "distinguishes nodes of different classes" do
          expect(Paragraph.new).not_to eq(Quotation.new)
        end
      end

      describe "#with" do
        it "returns a modified copy" do
          expect(paragraph.with(children: [greeting]).text).to eq("Hail, ")
        end

        it "leaves the original unchanged" do
          paragraph.with(children: [])
          expect(paragraph.text).to eq("Hail, Sir")
        end

        it "rejects attributes the node does not have" do
          expect { paragraph.with(level: 2) }.to raise_error(ArgumentError)
        end
      end

      describe "#rewrite" do
        let(:modernized) do
          section.rewrite { |node| (node == Text.new("Sir")) ? node.with(value: "Sire") : node }
        end

        it "replaces the nodes the block changes" do
          expect(modernized.text).to eq("To the Reader\n\nHail, Sire")
        end

        it "leaves the original tree unchanged" do
          modernized
          expect(section.text).to eq("To the Reader\n\nHail, Sir")
        end

        it "reuses unchanged subtrees" do
          expect(modernized.children.first).to equal(section.children.first)
        end

        it "returns the same tree when nothing changes" do
          expect(section.rewrite { |node| node }).to equal(section)
        end
      end
    end
  end
end
