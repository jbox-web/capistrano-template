# frozen_string_literal: true

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
