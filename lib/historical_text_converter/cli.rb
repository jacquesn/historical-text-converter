# frozen_string_literal: true

require "optparse"

module HistoricalTextConverter
  class CLI
    def self.run(arguments, output: $stdout, error: $stderr)
      new(arguments, output: output, error: error).run
    end

    def initialize(arguments, output:, error:)
      @arguments = arguments.dup
      @output = output
      @error = error
    end

    def run
      options = parse_options

      if options[:help]
        @output.puts help_text
        return 0
      end

      if options[:version]
        @output.puts HistoricalTextConverter::VERSION
        return 0
      end

      raise CLIError, "No command was supplied. Use --help for usage information."
    rescue OptionParser::ParseError, CLIError => e
      @error.puts "Error: #{e.message}"
      @error.puts "Use --help for usage information."
      1
    end

    private

    def parse_options
      options = {
        help: false,
        version: false
      }

      parser = OptionParser.new do |opts|
        opts.banner = "Usage: historical-text-converter [options]"

        opts.on("-h", "--help", "Display this help message") do
          options[:help] = true
        end

        opts.on("-v", "--version", "Display the application version") do
          options[:version] = true
        end
      end

      parser.parse!(@arguments)

      unless @arguments.empty?
        raise CLIError, "Unexpected argument: #{@arguments.first}"
      end

      options
    end

    def help_text
      <<~HELP
        Historical Text Converter #{HistoricalTextConverter::VERSION}

        Usage:
          historical-text-converter [options]

        Options:
          -h, --help       Display this help message
          -v, --version    Display the application version

        Milestone 1 provides the project foundation only.
        Historical-text conversion is not yet implemented.
      HELP
    end
  end
end
