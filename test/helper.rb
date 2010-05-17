require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'mocha'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'two_performant'

TwoPerformant.site = 'http://api.sandbox.2performant.com'

class Test::Unit::TestCase
end
