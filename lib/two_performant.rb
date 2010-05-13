require 'httparty'
require 'two_performant/oauth'

class TwoPerformant
  include HTTParty
  format :xml
  headers 'Content-Type' => 'text/xml'

  attr_accessor :user, :pass, :host, :version, :auth_type, :oauth, :oauth_request
	
	def initialize(auth_type, auth_obj, host) 
    if auth_type == :simple 
      self.class.basic_auth auth_obj[:user], auth_obj[:pass]
    elsif auth_type == :oauth 
      self.oauth = TwoPerformant::OAuth.new(auth_obj, host)
    else 
      return false
    end

    self.version = "v1.0"
    self.auth_type = auth_type
    self.host = host
    self.class.base_uri host
	end

  # =======
  #  Users 
  # =======
  def user_show(user_id)
    self.hook("/users/#{user_id}.xml", "user");
  end


  #  Display public information about the logged in user 
  def user_loggedin 
    self.hook("/users/loggedin.xml", "user");
  end

  # ===========
  #  Campaigns 
  # ===========

  #  List campaigns. Displays the first 6 entries by default. 
  def campaigns_list(category_id=nil, page=1, perpage=6) 
    request = {
      'category_id'  => category_id,
      'page'         => page,
      'perpage'      => perpage
    }
   
    self.hook("/campaigns.xml", "campaign", request, 'GET')
  end

  #  Search for campaigns 
  def campaigns_search(search, page = 1, perpage = 6) 
    request = {
      'page'    => page,
      'perpage' => perpage,
      'search'  => search
    }
         
    self.hook("/campaigns/search.xml", "campaign", request, 'GET')
  end

  #  Display public information about a campaign 
  def campaign_show(campaign_id) 
    self.hook("/campaigns/#{campaign_id}.xml", "campaign")
  end

  #  Affiliates: List campaigns which have the logged in user accepted 
  def campaigns_listforaffiliate 
    self.hook("/campaigns/listforaffiliate.xml", "campaign")
  end

  #  Merchants: List all campaigns created by the logged in user 
  def campaigns_listforowner 
    self.hook("/campaigns/listforowner.xml", "campaign")
  end

  #  Merchants: Display complete information about a campaign (only available to owner) 
  def campaign_showforowner(campaign_id) 
    self.hook("/campaigns/#{campaign_id}/showforowner.xml", "campaign")
  end
   
  #  Merchants: Update a campaign 
  def campaign_update(campaign_id, campaign) 
    request = {
      'campaign' => campaign
    }
    self.hook("/campaigns/#{campaign_id}.xml", "campaign", request, 'PUT')
  end
      
  #  Create a Deep Link. This method was created so it wouldn't make a request for every Quick Link.
  #  You may need to get some data before using it. 
  def campaign_quicklink(campaign_id, aff_code, redirect) 
    url = "#{self.host}/events/click?ad_type=quicklink&aff_code=#{aff_code}&unique=#{campaign_id}&redirect_to=#{redirect}"

    if (self.auth_type == :oauth) 
      url << "&app=#{self.oauth}"
    end

    url
  end

  # ============
  #  Sales
  # ============

  def sale_create(campaign_id, sale)
    request = {
      'sale' => sale
    }

    self.hook("/campaigns/#{campaign_id}/sales.xml", "sale", request, "POST")
  end

  # ============
  #  Leads
  # ============

  def lead_create(campaign_id, sale)
    request = {
      'lead' => lead
    }

    self.hook("/campaigns/#{campaign_id}/leads.xml", "lead", request, "POST")
  end

  # ============
  #  Affiliates 
  # ============

  #  Search for affiliates 
  def affiliates_search(search, page=1, perpage=6) 
    request = {
      'page'    => page,
      'perpage' => perpage,
      'search'  => search
    }

    self.hook("/affiliates/search", "user", request, 'GET')
  end

  #  Merchants: List affiliates approved in campaigns 
	def affiliates_listformerchant(campaign_id=nil) 
		request = {
      'campaign_id' => campaign_id
    }
    self.hook("/affiliates/listformerchant", "user", request, 'GET')
  end
       
  # =============
  #  Commissions 
  # =============
  
  #  Search for commissions.  Month: 01 to 12; Year: 20xx. Status: accepted, pending or rejected. nil if empty search.
  def commissions_search(options, campaign_id=nil, month=nil, year=nil, page=1, perpage=6) 
    request = {
      'campaign_id' => campaign_id,
      'month'       => month,
      'year'        => year,
      'page'        => page,
      'perpage'     => perpage
    }

    request.merge(options)

    self.hook("/commissions/search.xml", "commission", request, 'GET')
  end

  #  Merchants: List commissions on campaigns. Month: 01 to 12; Year: 20xx. 
  def commissions_listformerchant(campaign_id, month, year) 
    request = {
      'campaign_id' => campaign_id,
      'month'       => month,
      'year'        => year
    }

    self.hook("/commissions/listformerchant.xml", "campaign", request, 'GET')
  end

  #  Affiliates: List commissions on campaigns. Month: 01 to 12; Year: 20xx. 
  def commissions_listforaffiliate(campaign_id, month, year) 
    request = {
      'campaign_id' => campaign_id,
      'month'       => month,
      'year'        => year
    }

    self.hook("/commissions/listforaffiliate.xml", "commission", request, 'GET')
  end

	#  Merchant Campaign Owner or Affiliate Commission Owner: Show information about a commission 
  def commission_show(commission_id) 
    self.hook("/commissions/#{commission_id}.xml", "commission")
  end

  #  Merchant: Update a commission 
  def commission_update(commission_id, commission) 
    request = {
      'commission' => commission
    }
    self.hook("/commissions/#{commission_id}.xml", "commission", request, 'PUT')
  end

  # =======
  #  Sites 
  # =======

  #  List sites. Displays the first 6 entries by default. 
  def sites_list(category_id=nil, page=1, perpage=6) 
    request = {
      'category_id' => category_id,
      'page'        => page,
      'perpage'     => perpage
    }

    self.hook("/sites.xml", "site", request)
  end

  #  Display information about a site 
  def site_show(site_id) 
    self.hook("/sites/#{site_id}.xml", "site")
  end

  #  Search for sites 
  def sites_search(search, page=1, perpage=6) 
    request = {
      'page'    => page,
      'perpage' => perpage,
      'search'  => search
    }

    self.hook("/sites/search.xml", "site", request, 'GET')
  end

  #  Affiliates: List all sites created by the logged in user 
  def sites_listforowner 
    self.hook("/sites/listforowner.xml", "site")
  end

  #  Affiliates: Update a site 
  def site_update(site_id, site) 
    request = {
      'site' => site
    }
    self.hook("/sites/#{site_id}.xml", "site", request, 'PUT')
  end


  #  Affiliates: Destroy a site 
  def site_destroy(site_id) 
    self.hook("/sites/#{site_id}.xml", "site", request, 'DELETE')
  end

  # ============
  #  Text Links 
  # ============

  #  List text links from a campaign. Displays the first 6 entries by default. 
  def txtlinks_list(campaign_id, page=1, perpage=6) 
    request = {
      'page'    => page,
      'perpage' => perpage
    }

    self.hook("/campaigns/#{campaign_id}/txtlinks.xml", "txtlink", request, 'GET')
  end

  #  Display information about a text link 
  def txtlink_show(campaign_id, txtlink_id) 
    self.hook("/campaigns/#{campaign_id}/txtlinks/#{txtlink_id}.xml", "txtlink")
  end

  #  Search for text links in a campaign 
  def txtlinks_search(campaign_id, search, page=1, perpage=6, sort='date') 
    request = {
      'page'    => page,
      'perpage' => perpage,
      'search'  => search,
      'sort'    => sort,
    }

    self.hook("/campaigns/#{campaign_id}/txtlinks/search.xml", "txtlink", request, 'GET')
  end

  #  
  # Merchants: Create Text Link. 
  #
  # Txtlink must be a hash of:
  #   { "title" => "title",
  #     "url" => "url",
  #     "help" => "help"
  #   },  where "help" is optional
  
  def txtlink_create(campaign_id, txtlink) 
    request = {
      'txtlink' => txtlink
    }

    self.hook("/campaigns/#{campaign_id}/txtlinks.xml", "txtlink", request, 'POST')
  end

  #  Merchants: Update a text link 
  def txtlink_update(campaign_id, txtlink_id, txtlink) 
    request = {
      'txtlink' => txtlink
    }
    self.hook("/campaigns/#{campaign_id}/txtlinks/#{txtlink_id}.xml", "txtlink", request, 'PUT')
  end

  #  Merchants: Destroy a text link 
  def txtlink_destroy(campaign_id, txtlink_id) 
    self.hook("/campaigns/#{campaign_id}/txtlinks/#{txtlink_id}.xml", "txtlink", nil, 'DELETE')
  end

  # ============
  #  Text Ads 
  # ============

  #  List text ads from a campaign. Displays the first 6 entries by default. 
  def txtads_list(campaign_id, page=1, perpage=6) 
    request = {
      'page'    => page,
      'perpage' => perpage
    }

    self.hook("/campaigns/#{campaign_id}/txtads.xml", "txtad", request, 'GET')
  end

  #  Display information about a text ad 
  def txtad_show(campaign_id, txtad_id) 
    self.hook("/campaigns/#{campaign_id}/txtads/#{txtad_id}.xml", "txtad")
  end

  #  Search for text ads in a campaign 
  def txtads_search(campaign_id, search, page=1, perpage=6, sort='date') 
    request = {
      'page'    => page,
      'perpage' => perpage,
      'search'  => search,
      'sort'    => sort
    }

    self.hook("/campaigns/#{campaign_id}/txtads/search.xml", "txtad", request, 'GET')
  end

  #  
  # Merchants: Create Text Ad. 
  # Txtad must be a hash of:
  #   { "title" => "title",
  #     "content" => "content",
  #     "url" => "url",
  #     "help" => "help"
  #   },  where "help" is optional
  def txtad_create(campaign_id, txtad) 
    request = {
      'txtad' => txtad
    }
  
    self.hook("/campaigns/#{campaign_id}/txtads.xml", "txtad", request, 'POST')
  end


  #  Merchants: Update a text ad 
  def txtad_update(campaign_id, txtad_id, txtad) 
    request = {
      'txtad' => txtad
    }

    self.hook("/campaigns/#{campaign_id}/txtads/#{txtad_id}.xml", "txtad", request, 'PUT')
  end

  #  Merchants: Destroy a text ad 
  def txtad_destroy(campaign_id, txtad_id) 
    self.hook("/campaigns/#{campaign_id}/txtads/#{txtad_id}.xml", "txtad", nil, 'DELETE')
  end

  # =========
  #  Banners 
  # =========

  #  List banners from a campaign. Displays the first 6 entries by default. 
  def banners_list(campaign_id, page=1, perpage=6) 
    request = { 
      'page'    => page,
      'perpage' => perpage
    }

    self.hook("/campaigns/#{campaign_id}/banners.xml", "banner", request, 'GET')
  end

  #  Display information about a banner 
  def banner_show(campaign_id, banner_id) 
    self.hook("/campaigns/#{campaign_id}/banners/#{banner_id}.xml", "banner")
  end

  #  Search for banners in a campaign 
  def banners_search(campaign_id, search, page=1, perpage=6, sort='date') 
    request = {
      'page'    => page,
      'perpage' => perpage,
      'search'  => search,
      'sort'    => sort
    }

    self.hook("/campaigns/#{campaign_id}/banners/search.xml", "banner", request, 'GET')
  end

  # Merchants: Create a banner
  def banner_create(campaign_id, banner, banner_image_url)
    request = {
      'banner' => banner,
      'banner_picture' => { :url => banner_image_url }
    }

    self.hook("/campaigns/#{campaign_id}/banners.xml", "banner", request, 'POST')
  end

  #  Merchants: Update a banner 
  def banner_update(campaign_id, banner_id, banner) 
    request = {
      'banner' => banner
    }

    self.hook("/campaigns/#{campaign_id}/banners/#{banner_id}.xml", "banner", request, 'PUT')
  end

  #  Merchants: Destroy a banner 
  def banner_destroy(campaign_id, banner_id) 
    self.hook("/campaigns/#{campaign_id}/banners/#{banner_id}.xml", "banner", nil, 'DELETE')
  end

  # ===============
  #  Widget Stores 
  # ===============

  #  List Widget Stores from a Campaign 
  def product_stores_list(campaign_id) 
    request = { 
      'campaign_id' => campaign_id
    }

    self.hook("/product_stores.xml", "product-store", request)
  end

  #  Show a WidgetStore 
  def product_store_show(product_store_id) 
    self.hook("/product_stores/#{product_store_id}.xml", "product-store")
  end

  #  Show Products from a WidgetStore 
  def product_store_showitems(product_store_id, category=nil, page=1, perpage=6, uniq_products=nil) 
    request = {
      'category'      => category,
      'page'          => page,
      'perpage'       => perpage
    }

    request['uniq_products'] = uniq_products if (uniq_products)

    self.hook("/product_stores/#{product_store_id}/showitems.xml", "product-store-data", request)
  end

  #  Show a Product from a WidgetStore 
  def product_store_showitem(product_store_id, product_id) 
    request = {
      'product_id' => product_id
    }

    self.hook("/product_stores/#{product_store_id}/showitem.xml", "product-store-data", request)
  end


  #  Search for Products in a WidgetStore 
  def product_store_products_search(campaign_id, search, product_store_id='all', category=nil, page=1, perpage=6, sort='date', uniq_products=false) 
    request = {
      'page'          => page,
      'perpage'       => perpage,
      'search'        => search,
      'category'      => category,
      'campaign_id'   => campaign_id,
      'sort'          => sort
    }

    request['uniq_products'] = uniq_products if uniq_products

    product_store_id = 'all' if !product_store_id

    self.hook("/product_stores/#{product_store_id}/searchpr.xml", "product-store-data", request, 'GET')
  end

  #  Merchants: Update a WidgetStore 
  def product_store_update(product_store_id, product_store) 
    request = {
      'product_store' => product_store
    }

    self.hook("/product_stores/#{product_store_id}.xml", "product-store", request, 'PUT')
  end

  #  Merchants: Destroy a WidgetStore 
  def product_store_destroy(product_store_id) 
    self.hook("/product_stores/#{product_store_id}.xml", "product-store", nil, 'DELETE')
  end

  #  
  # Merchants: Create a WidgetStoreProduct. 
  # WidgetStoreProduct must be a hash of: 
  #   { "title" => "title",
  #     "description" => "desc",
  #     "caption" => "caption",
  #     "price" => "price(integer in RON)", 
  #     "promoted" => "promoted (0 or 1)",
  #     "category" => "category",
  #     "subcategory" => "subcategory", 
  #     "url" => "url", 
  #     "image_url" => "url to image location",
  #     "prid" => "product id"
  #   }
  def product_store_createitem(product_store_id, product) 
    request = {
      'product' => product
    }

    self.hook("/product_stores/#{product_store_id}/createitem.xml", "product-store-data", request, 'POST')
  end

  #  Merchants: Update a product 
  def product_store_updateitem(product_store_id, product_id, product) 
    request = {
      'product'      => product,
      'product_id'   => product_id
    }

    self.hook("/product_stores/#{product_store_id}/updateitem.xml", "product-store-data", request, 'PUT')
  end

  #  Merchants: Destroy a product 
  def product_store_destroyitem(product_store_id, product_id) 
    request = {
      'pr_id' => product_id
    }

    self.hook("/product_stores/#{product_store_id}/destroyitem.xml", "product-store-data", request, 'DELETE')
  end

  # =====================
  #  Affiliate Ad Groups 
  # =====================
  
  #  Affiliates: List Ad Groups 
  def ad_groups_list 
    self.hook("/ad_groups.xml", "ad_group", nil, "GET")
  end

  #  Affiliates: Display information about an Ad Group 
  def ad_group_show(ad_group_id) 
    self.hook("/ad_groups/#{ad_group_id}.xml", "ad_group", nil, "GET")
  end

  #  Affiliates: Destroy an Ad Group 
  def ad_group_destroy(ad_group_id) 
    self.hook("/ad_groups/#{ad_group_id}.xml", "ad_group", nil, "DELETE")
  end

	#  Affiliates: Delete an Tool from a Group. tooltype is one of 'txtlink', 'txtad' or 'banner'. 
  def ad_group_destroyitem(ad_group_id, tool_type, tool_id) 
    request = {
      'tool_type' => tool_type,
      'tool_id'   => tool_id
    }

    self.hook("/ad_groups/#{ad_group_id}/destroyitem.xml", "ad_group", request, "DELETE")
  end

  # ==========
  #  Messages 
  # ==========

  #  List received messages. Displays the first 6 entries by default. 
  def received_messages_list(page=1, perpage=6) 
    request = {
      'page'      => page,
      'perpage'   => perpage
    }

    self.hook("/messages.xml", "message", nil, "GET")
  end

  #  List sent messages. Displays the first 6 entries by default. 
  def sent_messages_list(page=1, perpage=6) 
    request = {
      'page'      => page,
      'perpage'   => perpage
    }

    self.hook("/messages/sent.xml", "message", nil, "GET")
  end

  #  Display information about a message 
  def message_show(message_id) 
    self.hook("/messages/#{message_id}.xml", "message")
  end

  #  Destroy a message 
  def message_destroy(message_id) 
    self.hook("/messages/#{message_id}.xml", "message", nil, 'DELETE')
  end


	def hook(path, expected, send = nil, method = 'GET') #:nodoc:
    params = normalize_params(send, method)
    
    if self.oauth
      result = self.oauth.send(method.downcase, "/#{version}#{path}", send, params)
    else
      result = self.class.send(method.downcase, "/#{version}#{path}", :body => params)
    end

    # scrap the container
    if result.respond_to? :values
      result.values.first 
    else
      result
    end
	end

  def normalize_params(params, method)
    hash_to_xml(:request => params).to_s
  end

  def hash_to_xml(var, document = nil)
    document = REXML::Document.new if document.nil?

    if var.respond_to? :keys
      var.keys.each do |key|
        hash_to_xml(var[key], document.add_element(key.to_s))
      end
    else
      document.add_text(var.to_s)
    end

    document
  end
end
