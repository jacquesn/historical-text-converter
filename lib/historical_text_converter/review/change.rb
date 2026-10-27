# frozen_string_literal: true

module HistoricalTextConverter
  module Review
    # One change a transformation made to one node (HTC-0019 T2). A
    # removed node has an empty replacement. rule names why, where the
    # transformation applies more than one.
    Change = Data.define(:transformation, :original, :replacement, :location, :rule) do
      def initialize(transformation:, original:, replacement:, location:, rule: nil)
        super
      end
    end
  end
end
