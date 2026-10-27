# frozen_string_literal: true

module HistoricalTextConverter
  module Transformations
    # What a transformation may use besides the Book (HTC-0019 T2): the
    # configuration and the change log, so no transformation depends on
    # global state.
    class Context
      attr_reader :configuration, :change_log

      def initialize(configuration: Configuration.new, change_log: Review::ChangeLog.new)
        @configuration = configuration
        @change_log = change_log
      end

      # The settings under transformations: for one transformation.
      def settings(key)
        settings = @configuration.transformations.fetch(key) do
          raise ConfigurationError, "No settings for transformation: #{key}"
        end
        return settings if settings.is_a?(Hash)

        raise ConfigurationError, "Settings for transformation #{key} must be a mapping"
      end

      def enabled?(key)
        enabled = settings(key).fetch("enabled", true)
        return enabled if [true, false].include?(enabled)

        raise ConfigurationError, "transformations.#{key}.enabled must be true or false"
      end
    end
  end
end
