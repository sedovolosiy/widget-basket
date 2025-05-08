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

    def subtotal
      product.price * qty
    end
  end
end
