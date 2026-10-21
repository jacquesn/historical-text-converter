# frozen_string_literal: true

require "yaml"

module HistoricalTextConverter
  class Configuration
    DEFAULT_PATH = File.expand_path("../../config/default.yml", __dir__)

    def initialize(path: nil)
      @settings = load_yaml(DEFAULT_PATH)

      return unless path

      @settings = deep_merge(@settings, load_yaml(path))
    end

    def [](key)
      @settings[key.to_s]
    end

    def fetch(key, *args, &block)
      @settings.fetch(key.to_s, *args, &block)
    end

    def profile
      fetch("profile")
    end

    def transformations
      fetch("transformations", {})
    end

    def to_h
      deep_dup(@settings)
    end

    private

    def load_yaml(path)
      contents = File.read(path)

      YAML.safe_load(
        contents,
        permitted_classes: [],
        aliases: false
      ) || {}
    rescue Errno::ENOENT
      raise ConfigurationError, "Configuration file not found: #{path}"
    rescue Psych::Exception => e
      raise ConfigurationError, "Invalid YAML configuration: #{path}: #{e.message}"
    end

    def deep_merge(left, right)
      left.merge(right) do |_key, left_value, right_value|
        if left_value.is_a?(Hash) && right_value.is_a?(Hash)
          deep_merge(left_value, right_value)
        else
          right_value
        end
      end
    end

    def deep_dup(value)
      case value
      when Hash
        value.each_with_object({}) do |(key, child), result|
          result[key] = deep_dup(child)
        end
      when Array
        value.map { |child| deep_dup(child) }
      else
        value
      end
    end
  end
end
