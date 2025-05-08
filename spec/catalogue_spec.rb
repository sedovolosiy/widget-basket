# frozen_string_literal: true

require "spec_helper"

RSpec.describe WidgetBasket::Catalogue do
  let(:product) { WidgetBasket::Product.new("A", "Test Product", 10) }
  let(:catalogue) { described_class.new([product]) }

  describe "#find" do
    it "finds a product by code" do
      expect(catalogue.find("A")).to eq(product)
    end

    it "raises an error if the product is not found" do
      expect { catalogue.find("B") }.to raise_error(WidgetBasket::Catalogue::ProductNotFoundError)
    end
  end
end
