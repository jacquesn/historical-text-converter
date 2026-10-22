# frozen_string_literal: true

module HistoricalTextConverter
  # The semantic Document Model: Parsers build it, Transformations change
  # it, and Writers consume it. It has no knowledge of HTML or any output
  # format.
  module Document
    def self.deep_freeze(value)
      case value
      when Hash
        value.to_h { |key, child| [deep_freeze(key), deep_freeze(child)] }.freeze
      when Array
        value.map { |child| deep_freeze(child) }.freeze
      else
        value.frozen? ? value : value.dup.freeze
      end
    end
  end
end

require_relative "document/metadata"
require_relative "document/node"
require_relative "document/block"
require_relative "document/inline"
require_relative "document/page_break"
require_relative "document/text"
require_relative "document/emphasis"
require_relative "document/superscript"
require_relative "document/note_reference"
require_relative "document/section"
require_relative "document/heading"
require_relative "document/paragraph"
require_relative "document/quotation"
require_relative "document/poem"
require_relative "document/list"
require_relative "document/list_item"
require_relative "document/footnote"
require_relative "document/book"
