# frozen_string_literal: true

require "widget_basket"
require "spec_helper"

RSpec.describe WidgetBasket::Offers::OfferSet do
  let(:product_a) { WidgetBasket::Product.new("A", "Product A", 100.0) }
  let(:product_b) { WidgetBasket::Product.new("B", "Product B", 50.0) }
  let(:items) do
    {
      "A" => WidgetBasket::LineItem.new(product_a),
      "B" => WidgetBasket::LineItem.new(product_b)
    }
  end

  # Mock offer class for testing priority
  class MockOffer < WidgetBasket::Offers::Base
    def initialize(discount_amount, priority: 0)
      super(priority: priority)
      @discount_amount = discount_amount
    end

    def discount(line_items, previous_discounts = 0.0)
      @discount_amount
    end
  end

  describe "#total_discount" do
    it "returns 0.0 when no offers are present" do
      offer_set = described_class.new([])
      expect(offer_set.total_discount(items, 150.0)).to eq(0.0)
    end

    it "applies single offer correctly" do
      offer = MockOffer.new(10.0)
      offer_set = described_class.new([offer])
      expect(offer_set.total_discount(items, 150.0)).to eq(10.0)
    end

    it "applies offers in priority order" do
      high_priority = MockOffer.new(20.0, priority: 10)
      low_priority = MockOffer.new(10.0, priority: 1)
      offer_set = described_class.new([low_priority, high_priority])
      
      # High priority offer should be applied first
      expect(offer_set.total_discount(items, 150.0)).to eq(30.0)
    end

    it "passes previous_discounts to subsequent offers" do
      first_offer = MockOffer.new(20.0, priority: 2)
      second_offer = MockOffer.new(10.0, priority: 1)
      
      # Create test offers that verify previous_discounts
      allow(second_offer).to receive(:discount) do |items, previous_discounts|
        expect(previous_discounts).to eq(20.0)
        10.0
      end

      offer_set = described_class.new([second_offer, first_offer])
      expect(offer_set.total_discount(items, 150.0)).to eq(30.0)
    end
  end

  describe "#add" do
    it "maintains offers sorted by priority" do
      offer_set = described_class.new([])
      medium = MockOffer.new(15.0, priority: 5)
      highest = MockOffer.new(20.0, priority: 10)
      lowest = MockOffer.new(10.0, priority: 1)

      offer_set.add(medium)
      offer_set.add(lowest)
      offer_set.add(highest)

      # Verify they're applied in priority order
      expect(offer_set.total_discount(items, 150.0)).to eq(45.0)
    end
  end
end