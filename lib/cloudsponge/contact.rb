module Cloudsponge
  class Contact

    def self.from_array(list)
      list.map { |contact_data| Contact.new(contact_data) }.compact
    end

    def initialize(contact_data)
      super()
      @contact_data = contact_data
      self
    end

    def name
      "#{self.first_name} #{self.last_name}"
    end
    
    def first_from(field)
      from_array = self.send(field)  
      return from_array && from_array.first && from_array.first[:value] unless field.to_sym == :address
      self.address && self.address.first && "#{self.address.first[:street]} #{self.address.first[:city]} #{self.address.first[:region]}".strip
    end
   
    def method_missing(method_sym, *arguments, &block)
      if @contact_data.keys.include? method_sym.to_s
        result = if @contact_data[method_sym.to_s].is_a?(String)
          @contact_data[method_sym.to_s]
        else
          process_array(method_sym.to_s, @contact_data[method_sym.to_s])
        end
        result
      else
        super
      end
    end

    private
    
    def process_array(key, content)
      method_name = "process_#{key}"
      if self.private_methods.include? method_name.to_sym
        send("process_#{key}", content)
      else
        send("process_unknown", content)
      end
    end
    
    def process_unknown(content)
      if content.is_a?(Hash)
        content.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
      else
        content
      end
    end
    
    def process_email(content)
      @emails = content && content.inject([]) do |memo, email|
        email = email.inject({}){|i,(k,v)| i[k.to_sym] = v; i}
        memo << {:value => email[:address], :type => email[:type]}
      end || []
      @emails
    end
    
    def process_phone(content)
      @phones = content && content.inject([]) do |memo, phone|
        phone = phone.inject({}){|i,(k,v)| i[k.to_sym] = v; i}
        memo << {:value => phone[:number], :type => phone[:type]}
      end || []
      @phones
    end
    
    def process_address(content)
      @addresses = content && content.inject([]) do |memo, address|
        memo << {
          :type => address['type'], 
          :street => address["street"], 
          :city => address["city"], 
          :region => address["region"], 
          :country => address["country"], 
          :postal_code => address["postal_code"], 
          :formatted => address["formatted"]}
      end || []
      @addresses
    end

  end

end
