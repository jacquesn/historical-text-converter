# frozen_string_literal: true

require "yaml"

module HistoricalTextConverter
  module Parsers
    module EEBO
      # Display forms for TCP glyphs (<g ref="char:NAME"/>), from the TCP
      # character table in config/tcp_glyphs.yml (HTC-0017).
      class GlyphTable
        DEFAULT_PATH = File.expand_path("../../../../config/tcp_glyphs.yml", __dir__)

        def self.default
          @default ||= new
        end

        def initialize(path: DEFAULT_PATH)
          @glyphs = YAML.safe_load_file(path).fetch("glyphs").freeze
        end

        # The display form for a ref such as "char:abquam", or nil if the
        # table does not define it.
        def display(ref)
          @glyphs.dig(ref.to_s.delete_prefix("char:"), "display")
        end

        def size
          @glyphs.size
        end
      end
    end
  end
end
