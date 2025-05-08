# frozen_string_literal: "true"

module WidgetBasket
  module Offers
    # "Buy one get the 2nd half‑price" for a specific product code
    class HalfPriceSecondItem < Base
      def initialize(target_code, priority: 0)
        @target_code = target_code
        super(priority: priority)
      end

      def apply(line_item, base_price = nil)
        return 0.0 unless line_item.product.code == @target_code && line_item.qty >= 2
        pairs = line_item.qty / 2  # each pair -> one item half‑price
        base_price ||= line_item.product.price
        round_discount(base_price * 0.5 * pairs)
      end

      # Calculates the discount for the target product in the given line items
      # @param line_items [Hash] The collection of line items
      # @param previous_discounts [Float] Not used in this implementation as the half-price
      #   offer is independent of other discounts. Parameter is reserved for future extensibility.
      # @return [Float] The calculated discount amount
      def discount(line_items, previous_discounts = 0.0)
        item = line_items[@target_code]
        return 0.0 unless item

        # Calculate discount based on original price
        apply(item)
      end

      protected

      def validate_configuration!
        raise InvalidOfferConfigurationError, "Target code cannot be nil" if @target_code.nil?
        raise InvalidOfferConfigurationError, "Target code must be a string" unless @target_code.is_a?(String)
        raise InvalidOfferConfigurationError, "Target code cannot be empty" if @target_code.empty?
      end
    end
  end
end
