require 'nokogiri'
require 'logger'
require 'two_performant/connection'
require 'two_performant/exceptions'
require 'two_performant/core_ext/benchmark'

module TwoPerformant
  def self.logger
    @logger ||= Logger.new STDOUT
  end

end

