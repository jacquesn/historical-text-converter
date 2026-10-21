# frozen_string_literal: true

module HistoricalTextConverter
  module Document
    # Verse. Its children are blocks, typically one per line; finer line
    # and stanza structure will be added when a source requires it.
    class Poem < Block
    end
  end
end
