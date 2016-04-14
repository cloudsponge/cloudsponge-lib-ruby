module Cloudsponge
  class Contact < ContactBase
    attribute :first_name
    attribute :last_name
    attribute :phones
    attribute :emails
    attribute :addresses
    attribute :groups
    attribute :dob
    attribute :birthday
    attribute :title
    attribute :companies
    attribute :job_title
    attribute :photos
    attribute :locations
    
    def initialize(contact_data)
      super()
      @contact_data = contact_data
      self
    end
    
    def self.from_array(list)
      list.map { |contact_data| Contact.new(contact_data) }.compact
    end

    def name
      "#{self.first_name} #{self.last_name}"
    end
   
    def email
      first_from(:emails)
    end
    
    def phone
      first_from(:phones)
    end

    def address
      first_from(:addresses)
    end

    def first_from(field)
      from_array = self.send(field)  
      return from_array && from_array.first && from_array.first[:value] unless field.to_sym == :addresses
      self.addresses && self.addresses.first && "#{self.addresses.first[:street]} #{self.addresses.first[:city]} #{self.addresses.first[:region]}".strip
    end
  end
end
