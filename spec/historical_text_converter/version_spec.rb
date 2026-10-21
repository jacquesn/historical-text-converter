# frozen_string_literal: true

RSpec.describe "HistoricalTextConverter::VERSION" do
  it "is defined" do
    expect(HistoricalTextConverter::VERSION).to be_a(String)
  end

  it "follows semantic versioning" do
    expect(HistoricalTextConverter::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
  end
end
