# frozen_string_literal: true

module HistoricalTextConverter
  # Records what transformations changed, so every change is reviewable.
  module Review
  end
end

require_relative "review/location"
require_relative "review/change"
require_relative "review/change_log"
