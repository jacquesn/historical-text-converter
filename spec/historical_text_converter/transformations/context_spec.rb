# frozen_string_literal: true

module HistoricalTextConverter
  module Transformations
    RSpec.describe Context do
      it "gives a transformation its settings" do
        expect(transformation_context.settings("remove_divider_characters")["characters"]).to eq(["∣", "¦"])
      end

      it "starts with an empty change log" do
        expect(transformation_context.change_log.count).to eq(0)
      end

      it "rejects a transformation with no settings" do
        expect { transformation_context.settings("no_such_step") }.to raise_error(ConfigurationError, /no_such_step/)
      end

      it "rejects settings that are not a mapping" do
        expect { transformation_context("step" => true).settings("step") }.to raise_error(ConfigurationError, /mapping/)
      end

      it "treats a transformation as enabled unless it says otherwise" do
        expect(transformation_context("step" => {}).enabled?("step")).to be(true)
      end

      it "rejects an enabled: value that is not true or false" do
        expect { transformation_context("step" => {"enabled" => "no"}).enabled?("step") }
          .to raise_error(ConfigurationError, /true or false/)
      end
    end
  end
end
