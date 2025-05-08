# frozen_string_literal: "true"

module WidgetBasket
  # Basket row: product + quantity
  class LineItem
    attr_reader :product, :qty

    def initialize(product)
      @product = product
      @qty     = 0
    end

    def increment
      @qty += 1
    end

    def set_quantity(value)
      raise ArgumentError, "Quantity cannot be negative" if value < 0
      @qty = value
    end

    def subtotal
      product.price * qty
    end
  end
end
