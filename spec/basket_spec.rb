# frozen_string_literal: true

require "widget_basket"
require "spec_helper"

RSpec.describe WidgetBasket::Basket do
  let(:products) do
    [
      WidgetBasket::Product.new("R01", "Red Widget", 32.95),
      WidgetBasket::Product.new("G01", "Green Widget", 24.95),
      WidgetBasket::Product.new("B01", "Blue Widget", 7.95)
    ]
  end
  let(:catalogue) { WidgetBasket::Catalogue.new(products) }
  let(:delivery_rule) do
    WidgetBasket::Delivery::Tiered.new([
      { limit: 90, fee: 0.0 },
      { limit: 50, fee: 2.95 },
      { limit: 0,  fee: 4.95 }
    ])
  end
  let(:offers) { [ WidgetBasket::Offers::HalfPriceSecondItem.new("R01") ] }
  subject(:basket) { described_class.new(catalogue: catalogue, delivery_rule: delivery_rule, offers: offers) }

  shared_examples "basket total" do |items, expected_total|
    it "#{items.join(", ")} → #{expected_total}" do
      items.each { |code| basket.add(code) }
      expect(basket.total).to eq(expected_total)
    end
  end

  include_examples "basket total", %w[B01 G01],        37.85
  include_examples "basket total", %w[R01 R01],        54.37
  include_examples "basket total", %w[R01 G01],        60.85
  include_examples "basket total", %w[B01 B01 R01 R01 R01], 98.27

  it "exposes line_items with correct quantities" do
    3.times { basket.add("B01") }
    li = basket.line_items.find { |i| i.product.code == "B01" }
    expect(li.qty).to eq(3)
    expect(li.subtotal).to eq(3 * 7.95)
  end

  it "returns zero for empty basket" do
    expect(basket.total).to eq(0.0)
  end

  let(:product) { WidgetBasket::Product.new("A", "Product A", 10) }
  let(:product_b) { WidgetBasket::Product.new("B", "Product B", 20) }
  let(:simple_catalogue) { WidgetBasket::Catalogue.new([product, product_b]) }
  let(:simple_delivery) { WidgetBasket::Delivery::Tiered.new([{limit: 0, fee: 0}]) }
  let(:simple_basket) { described_class.new(catalogue: simple_catalogue, delivery_rule: simple_delivery) }

  describe "#add" do
    it "adds a line item to the basket" do
      simple_basket.add("A")
      expect(simple_basket.line_items.first.product).to eq(product)
    end

    it "raises an error if the product code is not found" do
      expect { simple_basket.add("C") }.to raise_error(WidgetBasket::Catalogue::ProductNotFoundError)
    end
  end

  describe "quantity limits" do
    it "allows adding up to MAX_QUANTITY_PER_ITEM of the same item" do
      described_class::MAX_QUANTITY_PER_ITEM.times { simple_basket.add("A") }
      expect(simple_basket.line_items.first.qty).to eq(described_class::MAX_QUANTITY_PER_ITEM)
    end

    it "raises QuantityLimitExceededError when exceeding MAX_QUANTITY_PER_ITEM" do
      described_class::MAX_QUANTITY_PER_ITEM.times { simple_basket.add("A") }
      expect { simple_basket.add("A") }
        .to raise_error(WidgetBasket::Basket::QuantityLimitExceededError)
    end

    it "applies limits independently per item" do
      described_class::MAX_QUANTITY_PER_ITEM.times { simple_basket.add("A") }
      expect { simple_basket.add("B") }.not_to raise_error
    end
  end

  describe "total amount limits" do
    let(:expensive_product) { WidgetBasket::Product.new("E", "Expensive", described_class::MAX_TOTAL_AMOUNT / 2.0) }
    let(:catalogue_with_expensive) { WidgetBasket::Catalogue.new([product, product_b, expensive_product]) }
    let(:basket_with_expensive) { described_class.new(catalogue: catalogue_with_expensive, delivery_rule: simple_delivery) }

    it "allows orders up to MAX_TOTAL_AMOUNT" do
      2.times { basket_with_expensive.add("E") }
      expect(basket_with_expensive.total).to eq(described_class::MAX_TOTAL_AMOUNT)
    end

    it "raises TotalAmountExceededError when exceeding MAX_TOTAL_AMOUNT" do
      2.times { basket_with_expensive.add("E") }
      expect { basket_with_expensive.add("A") }
        .to raise_error(WidgetBasket::Basket::TotalAmountExceededError)
    end

    it "considers delivery fees when checking MAX_TOTAL_AMOUNT" do
      delivery_with_fee = WidgetBasket::Delivery::Tiered.new([{limit: 0, fee: 10.0}])
      
      near_limit_product = WidgetBasket::Product.new(
        "N",
        "Near Limit",
        described_class::MAX_TOTAL_AMOUNT - 5.0  # Changed from -15.0 to -5.0
      )
      catalogue = WidgetBasket::Catalogue.new([near_limit_product])
      basket = described_class.new(
        catalogue: catalogue,
        delivery_rule: delivery_with_fee
      )

      expect { basket.add("N") }
        .to raise_error(WidgetBasket::Basket::TotalAmountExceededError)
    end
  end

  describe "LineItem" do
    let(:line_item) { WidgetBasket::LineItem.new(product) }

    describe "#set_quantity" do
      it "sets the quantity when value is non-negative" do
        line_item.set_quantity(5)
        expect(line_item.qty).to eq(5)
      end

      it "raises ArgumentError for negative quantity" do
        expect { line_item.set_quantity(-1) }
          .to raise_error(ArgumentError, "Quantity cannot be negative")
      end
    end
  end
end
