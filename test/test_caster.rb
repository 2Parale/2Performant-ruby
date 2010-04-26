require 'helper'

NODE = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<user>
  <activated-at type="datetime">2009-09-08T12:02:02Z</activated-at>
  <agency-id type="integer" nil="true"></agency-id>
  <created-at type="datetime">2009-09-08T11:22:58Z</created-at>
  <id type="integer">1088</id>
  <locale>en</locale>
  <login>firenze</login>
  <remember-token nil="true"></remember-token>
  <remember-token-expires-at type="datetime" nil="true"></remember-token-expires-at>
  <role nil="false">merchant</role>
  <some-decimal type="decimal">100.0</some-decimal>
  <some-float type="float">100.0</some-float>
  <some-date type="date">2010-04-26</some-date>
  <signed-contract type="boolean">false</signed-contract>
  <suspend type="boolean">false</suspend>
  <updated-at type="datetime">2010-01-05T11:49:14Z</updated-at>
  <packets type="yaml">--- 
  - userbased
  </packets>
  <campaigns type="array">
    <campaign>
      <auto-affiliates type="boolean">false</auto-affiliates>
      <auto-update-url></auto-update-url>
      <category-id type="integer">3</category-id>
      <created-at type="datetime">2008-07-16T11:55:31Z</created-at>
      <description>bazbuz is a bazbuz is a bazbuz</description>
      <id type="integer">1</id>
      <main-url>http://www.bazbuz.com</main-url>
      <name>bazbuz</name>
      <packets>--- 
      - userbased
      </packets>
      <payper-type>leadsale</payper-type>
      <process-period type="integer">10</process-period>
      <suspend type="boolean">false</suspend>
      <updated-at type="datetime">2009-12-28T18:23:34Z</updated-at>
      <user-id type="integer">1088</user-id>
    </campaign>
    <campaign>
      <auto-affiliates type="boolean">false</auto-affiliates>
      <auto-update-url>http://foobar.com</auto-update-url>
      <category-id type="integer">6</category-id>
      <created-at type="datetime">2009-09-21T10:04:51Z</created-at>
      <description>foobar omg !</description>
      <id type="integer">2</id>
      <main-url>http://www.foobar.ro/</main-url>
      <name>foobar eats babies</name>
      <packets nil="true"></packets>
      <payper-type>lead</payper-type>
      <process-period type="integer">10</process-period>
      <suspend type="boolean">false</suspend>
      <updated-at type="datetime">2009-09-21T15:32:49Z</updated-at>
      <user-id type="integer">1088</user-id>
    </campaign>
  </campaigns>
</user>
XML


class TestResource < Test::Unit::TestCase
  def setup
    @node = Nokogiri::XML.parse(NODE, nil, nil, Nokogiri::XML::ParseOptions::NOBLANKS | Nokogiri::XML::ParseOptions::DEFAULT_XML)
    @user = @node.at('user')
  end

  should "typecast integers" do
    assert_equal 1088, TwoPerformant::Caster.typecast_xml_node(@user.at('id'))
  end

  should "typecast datetimes" do
    d = Time.parse('2009-09-08T11:22:58Z')
    assert_equal d, TwoPerformant::Caster.typecast_xml_node(@user.at('created-at'))
  end

  should "typecast strings" do
    assert_equal 'firenze', TwoPerformant::Caster.typecast_xml_node(@user.at('login'))
  end

  should "typecast nil" do
    assert_equal nil, TwoPerformant::Caster.typecast_xml_node(@user.at('remember-token'))
    assert_equal nil, TwoPerformant::Caster.typecast_xml_node(@user.at('remember-token-expires-at'))
  end

  should "only typecast nil if the value is true" do
    assert_equal 'merchant', TwoPerformant::Caster.typecast_xml_node(@user.at('role'))
  end

  should "typecast decimals" do
    assert_equal BigDecimal.new('100'), TwoPerformant::Caster.typecast_xml_node(@user.at('some-decimal'))
  end

  should "typecast floats" do
    assert_equal 100.0, TwoPerformant::Caster.typecast_xml_node(@user.at('some-float'))
  end

  should "typecast dates" do
    d = Date.parse('2010-04-26')
    assert_equal d, TwoPerformant::Caster.typecast_xml_node(@user.at('some-date'))
  end

  should "typecast yaml" do
    result = TwoPerformant::Caster.typecast_xml_node(@user.at('packets'))

    assert_equal 1, result.length
    assert_equal 'userbased', result[0]
  end

  should "typecast arrays as arrays comprised of classes named by their respective nodes' names" do
    result = TwoPerformant::Caster.typecast_xml_node(@user.at('campaigns'))
    assert_equal Array, result.class
    assert_equal 2, result.length
    assert_equal TwoPerformant::Resource::Campaign, result[0].class

    campaign = result[0]
    assert_equal 1088, campaign.user_id
  end

end
