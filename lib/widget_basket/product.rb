# frozen_string_literal: true

module WidgetBasket
  # Immutable value‑object that represents a product in the catalogue.
  Product = Struct.new(:code, :name, :price) do
    def to_s
      "#{code} ($#{format("%.2f", price)})"
    end
  end
end
