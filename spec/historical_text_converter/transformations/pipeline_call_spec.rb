# frozen_string_literal: true

# Milestone 5 acceptance: the cleanup pipeline on every fixture (HTC-0019).
module HistoricalTextConverter
  module Transformations
    RSpec.describe Pipeline, "#call" do
      fixtures = File.expand_path("../../fixtures/eebo", __dir__)

      def self.running_text(book)
        book.select { |node| RunningText.block?(node) }.map(&:text)
      end

      def self.gaps(book)
        book.grep(Document::Text).select { |node| node.metadata[:gap] }.map(&:value)
      end

      # The parsed words, with each line-end break joined as the pipeline
      # should join it: the marker, any whitespace after it within the
      # block, and the marker itself removed. The parser's own words are
      # checked against the source in parser_parse_with_report_spec.rb.
      def self.expected_words(book)
        running_text(book).flat_map { |text| text.gsub(/[∣¦]\s*(?=\S)/, "").delete("∣¦").split }.tally
      end

      Dir[File.join(fixtures, "*.xml")].sort.each do |path|
        context "with #{File.basename(path, ".xml")}" do
          parsed = Parsers::EEBO::Parser.new.parse(path)
          cleaned = described_class.new.call(parsed)
          text = running_text(cleaned)
          words = [text.flat_map(&:split).tally, expected_words(parsed)]
          gaps = [gaps(cleaned), gaps(parsed)]

          it "leaves no line-end break markers" do
            expect(text.grep(/[∣¦]/)).to be_empty
          end

          it "leaves no line breaks, runs of spaces, or whitespace at block edges" do
            expect(text.grep(/\n|\s{2}|\A\s|\s\z/)).to be_empty
          end

          it "keeps every word, joining line-end breaks" do
            expect(words.first).to eq(words.last)
          end

          it "leaves every gap untouched" do
            expect(gaps.first).to eq(gaps.last)
          end
        end
      end
    end
  end
end
