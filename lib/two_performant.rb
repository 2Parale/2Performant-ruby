require 'nokogiri'
require 'logger'
require 'two_performant/connection'
require 'two_performant/exceptions'
require 'two_performant/core_ext/benchmark'
require 'two_performant/core_ext/string'
require 'two_performant/resource'

module TwoPerformant
  @@site = nil

  def self.logger
    @logger ||= Logger.new STDOUT
  end

  def self.site
    @@site
  end

  def self.site=(value)
    @@site = value
  end

end

