module Cloudsponge
  class ContactBase
    def self.attribute(name)
      plural = {emails: "email", phones: "phone", addresses: "address"}
      
      if plural.keys.include? name
        define_method(name) do
          send("process_#{plural[name]}", @contact_data[plural[name]])
        end
      else
        define_method(name) do
          @contact_data[name.to_s]
        end
      end
    end

    private
    
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
