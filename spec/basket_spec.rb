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
end
