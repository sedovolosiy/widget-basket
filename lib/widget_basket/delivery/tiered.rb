# frozen_string_literal: "true"

module WidgetBasket
  module Delivery
    class InvalidThresholdsError < StandardError; end

    # Tiered fees, e.g.:
    # [
    #   {limit: 90, fee: 0},
    #   {limit: 50, fee: 2.95},
    #   {limit: 0,  fee: 4.95}
    # ]
    class Tiered < Base
      def initialize(thresholds)
        validate_thresholds!(thresholds)
        @thresholds = thresholds.sort_by { |t| t[:limit] }
      end

      def fee(subtotal)
        rule = @thresholds.reverse.find { |t| subtotal >= t[:limit] }
        rule ? rule[:fee].round(2) : @thresholds.last[:fee].round(2)
      end

      private

      def validate_thresholds!(thresholds)
        raise InvalidThresholdsError, "Thresholds cannot be empty" if thresholds.empty?
        raise InvalidThresholdsError, "All thresholds must have :limit and :fee" unless thresholds.all? { |t| t[:limit].is_a?(Numeric) && t[:fee].is_a?(Numeric) }
        raise InvalidThresholdsError, "Must include a base threshold (limit: 0)" unless thresholds.any? { |t| t[:limit] == 0 }
        
        # Check for overlapping ranges
        sorted = thresholds.sort_by { |t| t[:limit] }
        sorted.each_cons(2) do |lower, upper|
          if lower[:limit] == upper[:limit]
            raise InvalidThresholdsError, "Overlapping thresholds at limit #{lower[:limit]}"
          end
        end
      end
    end
  end
end
