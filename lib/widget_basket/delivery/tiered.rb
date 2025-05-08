# frozen_string_literal: "true"

module WidgetBasket
  module Delivery
    # Tiered fees, e.g.:
    # [
    #   {limit: 90, fee: 0},
    #   {limit: 50, fee: 2.95},
    #   {limit: 0,  fee: 4.95}
    # ]
    class Tiered < Base
      def initialize(thresholds)
        @thresholds = thresholds.sort_by { |t| t[:limit] }
      end

      def fee(subtotal)
        rule = @thresholds.reverse.find { |t| subtotal >= t[:limit] }
        rule ? rule[:fee] : 0.0
      end
    end
  end
end
