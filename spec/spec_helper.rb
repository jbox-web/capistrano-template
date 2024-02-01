# frozen_string_literal: true

require "tmpdir"

require "simplecov"

# Start SimpleCov
SimpleCov.start do
  add_filter "spec/"
end

# Configure RSpec
RSpec.configure do |config|
  config.order = :random
  Kernel.srand config.seed

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # disable monkey patching
  # see: https://relishapp.com/rspec/rspec-core/v/3-8/docs/configuration/zero-monkey-patching-mode
  config.disable_monkey_patching!
end

class FakeContext
  attr_reader :host

  def initialize(host: "localhost")
    @host = host
  end
end

class FakeRenderer
  attr_reader :as_str

  def initialize(as_str:)
    @as_str = as_str
  end
end

require "capistrano/template"
