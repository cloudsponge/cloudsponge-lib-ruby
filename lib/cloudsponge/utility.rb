module Cloudsponge
  
  require "net/http"
  require "net/https"
  require "uri"

  begin
    require 'json'
  rescue
  end
  
  class Utility
    
    def self.object_to_query(object)
      return object unless object.is_a? Hash
      object.map{ |k,v| "#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}" }.join('&')
    end
    
    def self.post_and_decode_response(url, params, auth)
      # post the response
      response = post_url(url, params, auth)
      decode_response(response)
    end

    def self.get_and_decode_response(full_url, auth)
      # get the response
      response = get_url(full_url, auth)
      decode_response(response)
    end
    
    def self.decode_response(response)
      if response.code_type == Net::HTTPOK
        # decode the response into an asscoiative array
        resp = decode_response_body(response.body, 'json')
        raise CsException.new(resp['error']['message'], response['code']) if resp['error']
      else
        raise CsException.new(response.body, response.code)
      end
      resp
    end

    def self.decode_response_body(response, format = 'json')
      # TODO: account for systems that use a different JSON parser. Look for json gem...
      # TODO: implement alternate formats: XML
      object = {'error' => {'message' => 'failed to parse data.', 'code' => 1}}
      begin
        object = ActiveSupport::JSON.decode(response)
      rescue
        begin 
          object = JSON.parse(response)
        rescue
        end
      end
      object
    end

    def self.get_url(url, auth)
      url = URI.parse(url)
      open_http(url, url.query, auth, :get)
    end

    def self.post_url(url, params, auth)
      url = URI.parse(url)
      open_http(url, params, auth, :post)
    end

    def self.open_http(url, params, auth, method)
      http = Net::HTTP.new(url.host, url.port)
      if url.port == 443
        http.use_ssl = true
      end 
      request = if method == :post
        Net::HTTP::Post.new(url.request_uri)
      else
        Net::HTTP::Get.new(url.request_uri)
      end
      request.set_form_data(params) if method == :post
      request.basic_auth(auth[:domain_key], auth[:domain_password])
      http.request(request)
    end
  end
end
