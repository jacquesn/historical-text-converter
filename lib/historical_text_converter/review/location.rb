# frozen_string_literal: true

module HistoricalTextConverter
  module Review
    # Where a change was made (HTC-0019 T2): the node's path of child
    # positions from the Book root, in the Book the transformation
    # received, and the nearest preceding printed page number, if any.
    Location = Data.define(:path, :page) do
      def initialize(path:, page: nil)
        super(path: path.dup.freeze, page: page)
      end

      def child(index)
        with(path: path + [index])
      end
    end
  end
end
