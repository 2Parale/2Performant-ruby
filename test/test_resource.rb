require 'helper'

class TestResource < Test::Unit::TestCase

  should "get the resource name from the current class" do
    @resource = TwoPerformant::Resource.new
    assert_equal 'resource', @resource.resource_name
  end

  should "get the resource name from the current class even if it is a child class" do
    class FooBarBaz < TwoPerformant::Resource; end
    @resource = FooBarBaz.new
    assert_equal 'foo_bar_baz', @resource.resource_name
  end

end
