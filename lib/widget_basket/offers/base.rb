# frozen_string_literal: "true"

module WidgetBasket
  module Offers
    class InvalidOfferConfigurationError < StandardError; end

    # Interface for discount strategies.
    class Base
      attr_reader :priority

      def initialize(priority: 0)
        @priority = priority
        validate_configuration!
      end

      # @param line_items [Hash{String=>LineItem}]
      # @param previous_discounts [Float] total discounts applied by higher priority offers
      # @return [Float] discount amount (positive number)
      def discount(line_items, previous_discounts = 0.0)
        0.0
      end

      protected

      def validate_configuration!
        true # Override in subclasses to add specific validations
      end

      def round_discount(amount)
        amount.round(2)
      end
    end
  end
end
