# frozen_string_literal: "true"

module WidgetBasket
  module Delivery
    # Interface for delivery‑fee strategies.
    class Base
      # @param subtotal [Float] amount after discounts
      # @return [Float] delivery fee
      def fee(_subtotal)
        0.0
      end
    end
  end
end
