# frozen_string_literal: true

module HistoricalTextConverter
  class Error < StandardError
  end

  class ConfigurationError < Error
  end

  class CLIError < Error
  end

  class DocumentError < Error
  end
end
