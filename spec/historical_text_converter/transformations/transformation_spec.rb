# frozen_string_literal: true

module HistoricalTextConverter
  module Transformations
    RSpec.describe Transformation do
      it "names itself after its class" do
        expect(Cleanup::RemoveDividerCharacters.new.name).to eq("RemoveDividerCharacters")
      end

      it "finds its settings under its snake-case name" do
        expect(Cleanup::RemoveDividerCharacters.key).to eq("remove_divider_characters")
      end

      it "requires subclasses to implement #apply" do
        expect { described_class.new.apply(book, transformation_context) }.to raise_error(NotImplementedError)
      end
    end
  end
end
