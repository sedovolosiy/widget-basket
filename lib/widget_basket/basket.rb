# frozen_string_literal: "true"

module WidgetBasket
  # Public API used by client code.
  class Basket
    MAX_QUANTITY_PER_ITEM = 99 # Reasonable limit for a single item
    MAX_TOTAL_AMOUNT = 10000.0 # Reasonable maximum order value

    class QuantityLimitExceededError < StandardError; end
    class TotalAmountExceededError < StandardError; end

    def initialize(catalogue:, delivery_rule:, offers: [])
      @catalogue = catalogue
      @delivery_rule = delivery_rule
      @offers = Offers::OfferSet.new(offers)
      @items = Hash.new { |h, code| h[code] = LineItem.new(@catalogue.find(code)) }
      @mutex = Mutex.new # For thread safety
    end

    # Add a product by code. Returns self for chaining.
    def add(code)
      @mutex.synchronize do
        validate_can_add!(code)
        @items[code].increment
      end
      self
    end

    # @return [Float] final total (2‑dp rounded)
    def total
      @mutex.synchronize do
        calculate_total
      end
    end

    # Convenience: expose immutable list of current items
    def line_items
      @mutex.synchronize { @items.values.freeze }
    end

    private

    def calculate_total
      return 0.0 if @items.empty?
      
      gross = @items.values.sum(&:subtotal)
      discounts = @offers.total_discount(@items, gross)
      subtotal = gross - discounts
      delivery = @delivery_rule.fee(subtotal)
      
      (subtotal + delivery).round(2)
    end

    def validate_can_add!(code)
      item = @items[code]
      if item.qty >= MAX_QUANTITY_PER_ITEM
        raise QuantityLimitExceededError, "Cannot add more than #{MAX_QUANTITY_PER_ITEM} of the same item"
      end

      # Calculate potential total including delivery fees by simulating the addition
      current_qty = item.qty
      item.set_quantity(current_qty + 1)
      potential_total = calculate_total  # This already includes delivery fees
      item.set_quantity(current_qty) # Reset quantity

      if potential_total > MAX_TOTAL_AMOUNT
        raise TotalAmountExceededError, "Adding this item would exceed the maximum order value of #{MAX_TOTAL_AMOUNT}"
      end
    end
  end
end
