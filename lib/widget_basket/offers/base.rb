# frozen_string_literal: "true"

module WidgetBasket
  module Offers
    # Interface for discount strategies.
    class Base
      # @param line_items [Hash{String=>LineItem}]
      # @return [Float] discount amount (positive number)
      def discount(_line_items)
        0.0
      end
    end
  end
end
