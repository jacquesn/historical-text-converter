# frozen_string_literal: true

require "fileutils"
require "tmpdir"

RSpec.describe HistoricalTextConverter::Configuration do
  context "with no custom path" do
    subject(:configuration) { described_class.new }

    it "loads the default profile" do
      expect(configuration.profile).to eq("conservative")
    end

    it "loads the default transformation settings" do
      expect(configuration.transformations["americanization"]).to eq("enabled" => false)
    end

    it "supports string and symbol keys" do
      expect(configuration[:profile]).to eq(configuration["profile"])
    end

    it "returns a copy from #to_h that cannot alter the configuration" do
      configuration.to_h["transformations"]["modernization"]["enabled"] = false

      expect(configuration.transformations["modernization"]["enabled"]).to be(true)
    end
  end

  context "with a custom path" do
    let(:dir) { Dir.mktmpdir }

    after { FileUtils.remove_entry(dir) }

    def write_yaml(contents)
      path = File.join(dir, "custom.yml")
      File.write(path, contents)
      path
    end

    it "deep-merges custom settings over the defaults" do
      path = write_yaml("transformations:\n  americanization:\n    enabled: true\n")

      expect(described_class.new(path: path).transformations.slice("modernization", "americanization"))
        .to eq("modernization" => {"enabled" => true}, "americanization" => {"enabled" => true})
    end

    it "raises a helpful error when the file does not exist" do
      expect { described_class.new(path: "/nonexistent/htc.yml") }
        .to raise_error(HistoricalTextConverter::ConfigurationError, /not found/)
    end

    it "raises a helpful error when the YAML is invalid" do
      path = write_yaml("transformations: [unclosed\n")

      expect { described_class.new(path: path) }
        .to raise_error(HistoricalTextConverter::ConfigurationError, /Invalid YAML/)
    end

    it "refuses YAML that would instantiate arbitrary objects" do
      path = write_yaml("created: 2024-01-01\n")

      expect { described_class.new(path: path) }
        .to raise_error(HistoricalTextConverter::ConfigurationError)
    end
  end
end
