# frozen_string_literal: true

module HistoricalTextConverter
  # Transformations turn one Book into another (architecture §17–20).
  module Transformations
  end
end

require_relative "transformations/context"
require_relative "transformations/transformation"
require_relative "transformations/running_text"
require_relative "transformations/running_text_transformation"
require_relative "transformations/cleanup/remove_artifacts"
require_relative "transformations/cleanup/remove_empty_blocks"
require_relative "transformations/cleanup/repair_broken_words"
require_relative "transformations/cleanup/remove_divider_characters"
require_relative "transformations/cleanup/normalize_whitespace"
require_relative "transformations/pipeline"
