# frozen_string_literal: true

require "spec_helper"

RSpec.describe WidgetBasket::Delivery::Tiered do
  subject(:rule) do
    described_class.new([
      { limit: 90, fee: 0.0 },
      { limit: 50, fee: 2.95 },
      { limit: 0,  fee: 4.95 }
    ])
  end

  it "returns correct delivery fee for order total" do
    expect(rule.fee(100)).to eq(0.0)
    expect(rule.fee(90)).to eq(0.0)
    expect(rule.fee(70)).to eq(2.95)
    expect(rule.fee(50)).to eq(2.95)
    expect(rule.fee(30)).to eq(4.95)
    expect(rule.fee(0)).to eq(4.95)
  end
end
