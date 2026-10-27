# frozen_string_literal: true

require "bundler/setup"
require "historical_text_converter"

Dir[File.join(__dir__, "support", "**", "*.rb")].each { |file| require file }

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.include TeiHelper
  config.include DocumentHelper
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
end
