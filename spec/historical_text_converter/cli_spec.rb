# frozen_string_literal: true

require "stringio"

RSpec.describe HistoricalTextConverter::CLI do
  let(:output) { StringIO.new }
  let(:error) { StringIO.new }

  def run_cli(*arguments)
    described_class.run(arguments, output: output, error: error)
  end

  describe "--help" do
    it "prints usage and exits successfully", :aggregate_failures do
      expect(run_cli("--help")).to eq(0)
      expect(output.string).to include("Usage:")
    end

    it "accepts the short form" do
      expect(run_cli("-h")).to eq(0)
    end
  end

  describe "--version" do
    it "prints the version and exits successfully", :aggregate_failures do
      expect(run_cli("--version")).to eq(0)
      expect(output.string.strip).to eq(HistoricalTextConverter::VERSION)
    end
  end

  describe "invalid invocations" do
    it "explains that no command was supplied", :aggregate_failures do
      expect(run_cli).to eq(1)
      expect(error.string).to include("No command was supplied")
    end

    it "reports an unknown option", :aggregate_failures do
      expect(run_cli("--bogus")).to eq(1)
      expect(error.string).to include("--bogus")
    end

    it "reports an unexpected argument", :aggregate_failures do
      expect(run_cli("convert")).to eq(1)
      expect(error.string).to include("Unexpected argument: convert")
    end

    it "always points the user to --help" do
      run_cli("--bogus")
      expect(error.string).to include("Use --help")
    end
  end
end
