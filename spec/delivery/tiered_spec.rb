# frozen_string_literal: true

require "widget_basket"
require "spec_helper"

RSpec.describe WidgetBasket::Delivery::Tiered do
  let(:valid_thresholds) do
    [
      { limit: 90, fee: 0.0 },
      { limit: 50, fee: 2.95 },
      { limit: 0,  fee: 4.95 }
    ]
  end

  describe "#initialize" do
    context "with invalid thresholds" do
      it "raises error when thresholds array is empty" do
        expect { described_class.new([]) }
          .to raise_error(WidgetBasket::Delivery::InvalidThresholdsError, "Thresholds cannot be empty")
      end

      it "raises error when threshold is missing limit" do
        invalid_thresholds = [
          { fee: 4.95 },
          { limit: 0, fee: 4.95 }
        ]
        expect { described_class.new(invalid_thresholds) }
          .to raise_error(WidgetBasket::Delivery::InvalidThresholdsError, "All thresholds must have :limit and :fee")
      end

      it "raises error when threshold is missing fee" do
        invalid_thresholds = [
          { limit: 50 },
          { limit: 0, fee: 4.95 }
        ]
        expect { described_class.new(invalid_thresholds) }
          .to raise_error(WidgetBasket::Delivery::InvalidThresholdsError, "All thresholds must have :limit and :fee")
      end

      it "raises error when limit is not numeric" do
        invalid_thresholds = [
          { limit: "50", fee: 2.95 },
          { limit: 0, fee: 4.95 }
        ]
        expect { described_class.new(invalid_thresholds) }
          .to raise_error(WidgetBasket::Delivery::InvalidThresholdsError, "All thresholds must have :limit and :fee")
      end

      it "raises error when fee is not numeric" do
        invalid_thresholds = [
          { limit: 50, fee: "2.95" },
          { limit: 0, fee: 4.95 }
        ]
        expect { described_class.new(invalid_thresholds) }
          .to raise_error(WidgetBasket::Delivery::InvalidThresholdsError, "All thresholds must have :limit and :fee")
      end

      it "raises error when base threshold (limit: 0) is missing" do
        invalid_thresholds = [
          { limit: 90, fee: 0.0 },
          { limit: 50, fee: 2.95 }
        ]
        expect { described_class.new(invalid_thresholds) }
          .to raise_error(WidgetBasket::Delivery::InvalidThresholdsError, "Must include a base threshold (limit: 0)")
      end

      it "raises error when thresholds have duplicate limits" do
        invalid_thresholds = [
          { limit: 50, fee: 0.0 },
          { limit: 50, fee: 2.95 },
          { limit: 0, fee: 4.95 }
        ]
        expect { described_class.new(invalid_thresholds) }
          .to raise_error(WidgetBasket::Delivery::InvalidThresholdsError, "Overlapping thresholds at limit 50")
      end
    end
  end

  describe "#fee" do
    subject(:delivery) { described_class.new(valid_thresholds) }

    it "returns correct fee for amount below first threshold" do
      expect(delivery.fee(0)).to eq(4.95)
      expect(delivery.fee(49.99)).to eq(4.95)
    end

    it "returns correct fee for amount at threshold boundaries" do
      expect(delivery.fee(50)).to eq(2.95)
      expect(delivery.fee(89.99)).to eq(2.95)
      expect(delivery.fee(90)).to eq(0.0)
    end

    it "returns correct fee for amount above highest threshold" do
      expect(delivery.fee(100)).to eq(0.0)
      expect(delivery.fee(1000)).to eq(0.0)
    end

    it "rounds fees to 2 decimal places" do
      thresholds = [
        { limit: 90, fee: 1.0/3.0 }, # Should round to 0.33
        { limit: 0, fee: 4.95 }
      ]
      delivery = described_class.new(thresholds)
      expect(delivery.fee(100)).to eq(0.33)
    end

    it "uses fallback fee for negative amounts" do
      expect(delivery.fee(-10)).to eq(4.95)
    end
  end
end
