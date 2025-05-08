Example of usages:

require_relative "lib/widget_basket"

include WidgetBasket

products = [
  Product.new("R01", "Red Widget", 32.95),
  Product.new("G01", "Green Widget", 24.95),
  Product.new("B01", "Blue Widget", 7.95)
]
catalogue = Catalogue.new(products)

delivery_rule = Delivery::Tiered.new([
  {limit: 90, fee: 0},
  {limit: 50, fee: 2.95},
  {limit: 0,  fee: 4.95}
])

offers = [Offers::HalfPriceSecondItem.new("R01")]

basket = Basket.new(catalogue: catalogue, delivery_rule: delivery_rule, offers: offers)

%w[B01 G01].each { |code| basket.add(code) }
puts basket.total    # => 37.85
