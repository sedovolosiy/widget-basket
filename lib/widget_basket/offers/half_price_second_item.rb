# frozen_string_literal: "true"

module WidgetBasket
  module Offers
    # "Buy one get the 2nd half‑price" for a specific product code
    class HalfPriceSecondItem < Base
      def initialize(target_code)
        @target_code = target_code
      end

      def apply(line_item)
        return 0.0 unless line_item.product.code == @target_code && line_item.qty >= 2
        pairs = line_item.qty / 2  # each pair -> one item half‑price
        (line_item.product.price * 0.5 * pairs).round(2)
      end

      def discount(line_items)
        item = line_items[@target_code]
        apply(item) if item
      end
    end
  end
end
