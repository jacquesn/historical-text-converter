# frozen_string_literal: true

require "tmpdir"

module HistoricalTextConverter
  RSpec.describe Parser do
    let(:recording_parser) do
      Class.new(described_class) do
        def parse_string(source) = "parsed: #{source}"
      end
    end

    it "reads the file and parses its contents" do
      Dir.mktmpdir do |dir|
        File.write(File.join(dir, "source.txt"), "text")
        expect(recording_parser.new.parse(File.join(dir, "source.txt"))).to eq("parsed: text")
      end
    end

    it "raises ParseError for a missing file" do
      expect { recording_parser.new.parse("/nonexistent/source.xml") }
        .to raise_error(ParseError, %r{Cannot read source file: /nonexistent/source.xml})
    end

    it "requires subclasses to implement #parse_string" do
      expect { described_class.new.parse_string("") }.to raise_error(NotImplementedError)
    end
  end
end
