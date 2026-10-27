# frozen_string_literal: true

# Milestone 4 acceptance: every fixture parses with every word kept and
# nothing unrecognized (HTC-0018).
module HistoricalTextConverter
  module Parsers
    module EEBO
      RSpec.describe Parser, "#parse_with_report" do
        fixtures = File.expand_path("../../../fixtures/eebo", __dir__)

        Dir[File.join(fixtures, "*.xml")].sort.each do |path|
          context "with #{File.basename(path, ".xml")}" do
            book, report = described_class.new.parse_with_report(path)

            it "reports nothing unrecognized" do
              expect(report.entries).to be_empty
            end

            it "keeps every word of the source" do
              expect(SourceWords.parsed(book)).to eq(SourceWords.tally(File.read(path)))
            end
          end
        end

        {
          "A19568" => ->(book) { book.body.children.map(&:kind).uniq == [:text] },
          "A59445" => ->(book) { book.grep(Document::Speech).size > 100 },
          "A95820" => ->(book) { book.grep(Document::Table).any? && book.grep(Document::Section).any? { |s| s.kind == :floating_text } },
          "A10388" => ->(book) { book.grep(Document::Poem).any? && book.grep(Document::Line).any? },
          "A32628" => ->(book) { book.grep(Document::Figure).any? },
          "A54309" => ->(book) { book.grep(Document::Section).map(&:kind).include?(:closer) },
          "A45601" => ->(book) { book.grep(Document::Section).map(&:kind).include?(:postscript) }
        }.each do |id, structure|
          it "builds the structure #{id} was chosen for" do
            expect(structure.call(described_class.new.parse(File.join(fixtures, "#{id}.xml")))).to be(true)
          end
        end
      end
    end
  end
end
