module Cloudsponge
  
  require "net/http"
  require "net/https"
  require "uri"

  begin
    require 'json'
    FORMAT = :json
  rescue
    require 'rexml/document'
    FORMAT = :xml
  end
  
  class Utility
    
    def self.object_to_query(object)
      return object unless object.is_a? Hash
      object.map{ |k,v| "#{URI.encode(k.to_s)}=#{URI.encode(v.to_s)}" }.join('&')
    end
    
    def self.post_and_decode_response(url, params)
      # post the response
      response = post_url(url, params)
      decode_response(response)
    end

    def self.get_and_decode_response(full_url)
      # get the response
      response = get_url(full_url)
      decode_response(response)
    end
    
    def self.decode_response(response)
      if response.code_type == Net::HTTPOK
        # decode the response into an asscoiative array
        # resp = decode_response_body(response.body, 'json')
        resp = decode_response_body(response.body, FORMAT)
        raise CsException.new(resp['error']['message'], response['code']) if resp['error']
      else
        raise CsException.new(response.body, response.code)
      end
      resp
    end

    def self.decode_response_body(response, format)
      # TODO: account for systems that use a different JSON parser. Look for json gem...
      # TODO: implement alternate formats: XML
      object = case format
      when :json
        begin
          ActiveSupport::JSON.decode(response)
        rescue
          JSON.parse(response) rescue PARSER_ERROR
        end
      when :xml
        from_xml(REXML::Document.new(response)) rescue PARSER_ERROR
      else
        PARSER_ERROR
      end
      object
    end

    def self.get_url(url)
      url = URI.parse(url)
      open_http(url).get("#{url.path}?#{url.query}")
    end

    def self.post_url(url, params)
      url = URI.parse(url)
      open_http(url).post("#{url.path}","#{object_to_query(params)}")
    end

    def self.open_http(url)
      http = Net::HTTP.new(url.host, url.port)
      # @csimport_http.read_timeout = @timeout || 30
      if url.port == 443
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end
      http.start unless http.started?
      http
    end
    
    def self.from_xml(doc)
      doc.elements.inject({}) do |memo, element|
        name = element.name && element.name.gsub(/([A-Z]+)/){ |match| "_#{match[0]}" }.downcase
        value = case element.elements.length
        when 0
          element.value || element.text
        when 1
          element 
        end
        memo[name] = element.value || element.text
        memo
      end
    end
    
    PARSER_ERROR = {'error' => {'message' => 'failed to parse data.', 'code' => 1}}
    
  end
end