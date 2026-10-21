# frozen_string_literal: true

require "spec_helper"

RSpec.describe HistoricalTextConverter do
  it "loads the main library" do
    expect(described_class).to be_a(Module)
  end

  it "exposes the expected namespace" do
    expect(described_class.name).to eq("HistoricalTextConverter")
  end
end
