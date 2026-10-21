# frozen_string_literal: true

module HistoricalTextConverter
  module Document
    # One entry in a List. It contains blocks, so items can hold several
    # paragraphs or a nested list.
    class ListItem < Block
    end
  end
end
