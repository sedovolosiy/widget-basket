# frozen_string_literal: true

require "simplecov"
SimpleCov.start

require "bundler/setup"
require "widget_basket"

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.filter_gems_from_backtrace "rspec"

  # config.order = :random
end
