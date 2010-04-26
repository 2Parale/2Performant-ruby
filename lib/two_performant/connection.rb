require 'net/http'
require 'benchmark'
require 'uri'

module TwoPerformant
  class Connection
    attr_accessor :site, :user, :password, :timeout
    
    FORMAT = {
      :xml => 'text/xml'
    }

    HTTP_FORMAT_HEADER_NAMES = {  :get => 'Accept',
      :put => 'Content-Type',
      :post => 'Content-Type',
      :delete => 'Accept',
      :head => 'Accept'
    }

    def initialize(site, options = {})
      @site = site.is_a?(URI) ? site : URI.parse(site)
      @user = URI.decode(@site.user) if @site.user
      @password = URI.decode(@site.password) if @site.password

      @timeout = options[:timeout] || 60
    end

    def get(path, headers = {})
      request('get', path, build_request_headers(headers, :get))
    end

    def delete(path, headers = {})
      request('delete', path, build_request_headers(headers, :delete))
    end

    def post(path, body = '', headers = {})
      request('post', path, body, build_request_headers(headers, :post))
    end

    def put(path, body = '', headers = {})
      request('put', path, body, build_request_headers(headers, :put))
    end

    def request(method, path, *arguments)
      logger.info "#{method.to_s.upcase} #{site.scheme}://#{site.host}:#{site.port}#{path}" if logger
      response = nil
      ms = Benchmark.ms { response = http.send(method, path, *arguments) }
      logger.info "--> %d %s (%d %.0fms)" % [response.code, response.message, response.body ? response.body.length : 0, ms] if logger
      handle_response(response)
    rescue Timeout::Error => e
      raise TwoPerformant::Exceptions::Timeout
    end

    def handle_response(response)
      Nokogiri::XML.parse(response.body, nil, nil, Nokogiri::XML::ParseOptions::NOBLANKS | Nokogiri::XML::ParseOptions::DEFAULT_XML)
    end

    def http
      http = Net::HTTP.new(@site.host, @site.port)

      if @timeout
        http.open_timeout = @timeout
        http.read_timeout = @timeout
      end

      http
    end

    def default_header
      @default_header ||= {}
    end

    # Builds headers for request to remote service.
    def build_request_headers(headers, http_method=nil)
      authorization_header.update(default_header).update(http_format_header(http_method)).update(headers)
    end

    # Sets authorization header
    def authorization_header
      (@user || @password ? { 'Authorization' => 'Basic ' + ["#{@user}:#{ @password}"].pack('m').delete("\r\n") } : {})
    end

    def http_format_header(http_method)
      {HTTP_FORMAT_HEADER_NAMES[http_method] => FORMAT[:xml]}
    end

    def logger #:nodoc:
      TwoPerformant.logger
    end
  end
end
