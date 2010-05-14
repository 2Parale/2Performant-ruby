require 'helper'

class TestResource < Test::Unit::TestCase

  should "get the resource name from the current class" do
    @resource = TwoPerformant::Resource::Base.new
    assert_equal 'bases', @resource.resource_name
  end

  should "get the resource name from the current class even if it is a child class" do
    class FooBarBaz < TwoPerformant::Resource::Base; end
    @resource = FooBarBaz.new
    assert_equal 'foo_bar_bazs', @resource.resource_name
  end

  context "with a resource" do
    setup do
      node = Nokogiri::XML.parse(<<-XML)
      <campaign>
      <allow-apps type="boolean">true</allow-apps>
      <auto-affiliates type="boolean">false</auto-affiliates>
      <boolean type="boolean">false</boolean>
      <category-id type="integer">22</category-id>
      <cookie-life type="integer">186</cookie-life>
      <created-at type="datetime">2009-12-09T08:32:24-11:00</created-at>
      <default-lead-commission-rate type="decimal" nil="true"/>
      <default-lead-commission-type>fixed</default-lead-commission-type>
      <default-sale-commission-rate type="decimal">10.0</default-sale-commission-rate>
      <default-sale-commission-type>percent</default-sale-commission-type>
      <description>
      Tuatara is 100% dedicated to the Urban Style. Here you will always find the latest collections from the biggest brands in the world.

      The latest trends delivered with an eye to detail represents the Tuatara essence.
      </description>
      <id type="integer">1</id>
      <main-url>http://www.tuatara.ro</main-url>
      <name>Tuatara</name>
      <packets type="yaml">--- [] </packets>
      <payper-type>sale</payper-type>
      <process-period type="integer">10</process-period>
      <suspend type="boolean">false</suspend>
      <tos nil="true"/>
      <unique-code>296f9f580</unique-code>
      <updated-at type="datetime">2010-04-15T09:39:40-11:00</updated-at>
      <user-id type="integer">3</user-id>
      </campaign>
      XML
      @resource = TwoPerformant::Resource::Base.new(node.children.first)
    end

    should "direct methods to the xml node when they are defined" do
      assert_equal 'fixed', @resource.default_lead_commission_type
      assert_equal 'http://www.tuatara.ro', @resource.main_url
      assert_equal 'sale', @resource.payper_type
      assert_equal 'Tuatara', @resource.name
    end

    should "define methods to access the value after initial access" do
      assert_equal false, @resource.respond_to?(:name)

      assert_equal 'Tuatara', @resource.name

      assert @resource.respond_to?(:name)
    end

    should "infer type from the type field" do
      assert_equal true, @resource.allow_apps
    end
  end

end
