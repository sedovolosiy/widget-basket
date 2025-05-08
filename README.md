# Widget Basket System - Acme Widget Co

[![Tests](https://github.com/sedovolosiy/widget-basket/actions/workflows/test.yml/badge.svg)](https://github.com/sedovolosiy/widget-basket/actions/workflows/test.yml)

A Ruby implementation of a shopping basket system for Acme Widget Co, providing a flexible solution for product management, delivery charges, and special offers.

## Overview

This system implements a proof of concept for Acme Widget Co's new sales system, featuring:
- Product catalogue management
- Tiered delivery charges based on order value
- Special offers implementation (e.g., buy-one-get-one-half-price)
- Continuous Integration with GitHub Actions testing on multiple Ruby versions (3.0 - 3.4)

## Products

The system currently includes the following products:

| Product Code | Name         | Price  |
|-------------|--------------|--------|
| R01         | Red Widget   | $32.95 |
| G01         | Green Widget | $24.95 |
| B01         | Blue Widget  | $7.95  |

## Delivery Charges

Delivery costs are calculated based on the total order value:
- Orders under $50: $4.95 delivery fee
- Orders under $90: $2.95 delivery fee
- Orders $90 or more: FREE delivery

## Special Offers

Current implemented offers:
- Buy one Red Widget (R01), get the second half price

## Usage

Here's an example of how to use the basket system:

```ruby
require_relative "lib/widget_basket"

include WidgetBasket

# Initialize product catalogue
products = [
  Product.new("R01", "Red Widget", 32.95),
  Product.new("G01", "Green Widget", 24.95),
  Product.new("B01", "Blue Widget", 7.95)
]
catalogue = Catalogue.new(products)

# Setup delivery rules
delivery_rule = Delivery::Tiered.new([
  {limit: 90, fee: 0},
  {limit: 50, fee: 2.95},
  {limit: 0,  fee: 4.95}
])

# Configure special offers
offers = [Offers::HalfPriceSecondItem.new("R01")]

# Create and use basket
basket = Basket.new(catalogue: catalogue, delivery_rule: delivery_rule, offers: offers)

# Add items to basket
%w[B01 G01].each { |code| basket.add(code) }
puts basket.total    # => 37.85
```

## Example Scenarios

Here are some example baskets and their expected totals:

1. B01, G01 = $37.85
   - Products: $32.90 ($7.95 + $24.95)
   - Delivery: $4.95 (under $50)
   - Total: $37.85

2. R01, R01 = $54.37
   - Products: $49.42 ($32.95 + $16.47) [second item half price]
   - Delivery: $4.95 (under $50)
   - Total: $54.37

3. R01, G01 = $60.85
   - Products: $57.90 ($32.95 + $24.95)
   - Delivery: $2.95 (under $90)
   - Total: $60.85

4. B01, B01, R01, R01, R01 = $98.27
   - Products: $98.27 ($7.95 + $7.95 + $32.95 + $16.47 + $32.95)
   - Delivery: $0 (over $90)
   - Total: $98.27

## Implementation Details

The system is implemented using the following components:
- `Basket`: Main class handling the shopping cart functionality
- `Catalogue`: Manages the product list and lookup
- `Product`: Represents individual products with code, name, and price
- `Delivery::Tiered`: Implements tiered delivery charge rules
- `Offers::HalfPriceSecondItem`: Implements the half-price second item offer

## Running Tests

The system includes a comprehensive test suite. To run the tests:

```bash
bundle install
bundle exec rspec
```
