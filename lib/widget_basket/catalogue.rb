# frozen_string_literal: true

module WidgetBasket
  # A lookup table that returns a product by its code.
  class Catalogue
    class ProductNotFoundError < KeyError; end

    def initialize(products = [])
      @index = products.each_with_object({}) { |p, h| h[p.code] = p.freeze }.freeze
    end

    # @raise [ProductNotFoundError] if code is not found
    def find(code)
      @index.fetch(code)
    rescue KeyError
      raise ProductNotFoundError, "Product with code '#{code}' not found"
    end

    # @return [Array<Product>] all products in the catalogue
    def all
      @index.values
    end
  end
end
