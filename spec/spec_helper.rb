require 'simplecov'
SimpleCov.start

require_relative '../lib/denouncer'
require 'rspec'

RSpec.configure do |config|

  config.formatter = :documentation
  config.tty = true
  config.color = true

  config.mock_with :rspec do |mocks|
    mocks.syntax = [:expect, :should]
  end
end
