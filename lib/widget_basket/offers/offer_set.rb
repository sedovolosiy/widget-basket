# frozen_string_literal: true

module WidgetBasket
  module Offers
    class OfferSet
      def initialize(offers = [])
        @offers = offers.sort_by { |o| -(o.respond_to?(:priority) ? o.priority : 0) }
      end

      def total_discount(line_items, gross_total)
        return 0.0 if @offers.empty?

        # Apply offers in order of priority
        @offers.reduce(0.0) do |total_discount, offer|
          discount = offer.discount(line_items, total_discount)
          total_discount + discount
        end.round(2)
      end

      def add(offer)
        @offers << offer
        @offers.sort_by! { |o| -(o.respond_to?(:priority) ? o.priority : 0) }
        self
      end
    end
  end
end
