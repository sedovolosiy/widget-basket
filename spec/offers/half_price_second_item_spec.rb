# frozen_string_literal: true

require "widget_basket"
require "spec_helper"

RSpec.describe WidgetBasket::Offers::HalfPriceSecondItem do
  let(:product) { WidgetBasket::Product.new("A", "Test Product", 10.0) }
  let(:catalogue) { WidgetBasket::Catalogue.new([product]) }
  let(:item_hash) do
    h = {}
    h["A"] = WidgetBasket::LineItem.new(product)
    h
  end
  subject(:offer) { described_class.new("A") }

  describe "#apply" do
    it "applies half price discount to every second item" do
      2.times { item_hash["A"].increment }
      expect(offer.apply(item_hash["A"])).to eq(5.0)

      item_hash["A"].increment
      expect(offer.apply(item_hash["A"])).to eq(5.0)

      item_hash["A"].increment
      expect(offer.apply(item_hash["A"])).to eq(10.0)
    end

    it "returns zero if product code does not match" do
      other_product = WidgetBasket::Product.new("B", "Other Product", 20.0)
      other_line_item = WidgetBasket::LineItem.new(other_product)
      2.times { other_line_item.increment }
      
      expect(offer.apply(other_line_item)).to eq(0.0)
    end
  end
end
