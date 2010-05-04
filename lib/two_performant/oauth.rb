require 'oauth'

class TwoPerformant
  class OAuth
    attr_accessor :access_token, :consumer

    def initialize(options, host)
      consumer = ::OAuth::Consumer.new(options[:consumer_token], options[:consumer_secret], {:site => host})
      @access_token = ::OAuth::AccessToken.new(consumer, options[:access_token], options[:access_secret])
      @headers = { 'Accept' => 'application/xml', 'Content-Type' => 'application/xml' }
    end

    def get(path, params_hash, params_xml) 
      params_hash ||= {}
      response = access_token.get("#{path}?#{params_hash.to_params}")
      Crack::XML.parse(response.body)
    end

    def post(path, params_hash, params_xml) 
      response = access_token.post(path, params_xml, @headers)
      Crack::XML.parse(response.body)
    end

    def put(path, params_hash, params_xml) 
      response = access_token.put(path, params_xml, @headers)
      Crack::XML.parse(response.body)
    end

    def delete(path, params) 
      response = access_token.delete("#{path}?#{params.to_params}")
      Crack::XML.parse(response.body)
    end
  end
end
