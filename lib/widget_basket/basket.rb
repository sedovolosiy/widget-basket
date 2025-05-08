# frozen_string_literal: "true"

module WidgetBasket
  # Public API used by client code.
  class Basket
    def initialize(catalogue:, delivery_rule:, offers: [])
      @catalogue     = catalogue
      @delivery_rule = delivery_rule
      @offers        = offers
      @items         = Hash.new { |h, code| h[code] = LineItem.new(@catalogue.find(code)) }
    end

    # Add a product by code.  Returns self for chaining.
    def add(code)
      @items[code].increment
      self
    end

    # @return [Float] final total (2‑dp rounded)
    def total
      return 0.0 if @items.empty?
      
      gross     = @items.values.sum(&:subtotal)
      discounts = @offers.sum { |offer| offer.discount(@items) }
      delivery  = @delivery_rule.fee(gross - discounts)
      (gross - discounts + delivery).round(2)
    end

    # Convenience: expose immutable list of current items
    def line_items
      @items.values.freeze
    end
  end
end
