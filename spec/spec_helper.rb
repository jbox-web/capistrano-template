# frozen_string_literal: true

require 'simplecov'

# Start SimpleCov
SimpleCov.start do
  add_filter 'spec/'
end

# Configure RSpec
RSpec.configure do |config|
  config.order = :random
  Kernel.srand config.seed
end

require 'capistrano/template'
