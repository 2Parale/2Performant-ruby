require 'benchmark'

module Benchmark
  def self.ms
    1000 * self.realtime { yield }
  end
end
