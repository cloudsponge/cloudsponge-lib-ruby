# CloudSponge.com Ruby Library
# http://www.cloudsponge.com
# Copyright (c) 2010 Cloud Copy, Inc.
# Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
# 
# Written by Graeme Rouse
# graeme@cloudsponge.com

module Cloudsponge
  # Constants
  URL_BASE      = "https://api.cloudsponge.com/"
  BEGIN_PATH    = "begin_import/"
  CONSENT_PATH  = "user_consent/"
  IMPORT_PATH   = "import/"
  APPLET_PATH   = "desktop_applet/"
  EVENTS_PATH   = "events/"
  CONTACTS_PATH = "contacts/"

  class ContactImporter
    attr_accessor :key, :password, :import_id

    def initialize(key = nil, password = nil, import_id = nil, opts = {})
      @key, @password, @import_id, @options = [key, password, import_id, opts]
    end

    # guesses the most appropriate invocation for begin_import_xxx()
    #   returns an array of possible objects
    #    [
    #      :import_id => <import_id>,
    #      :consent_url => nil | <consent_url>,
    #      :applet_tag  => nil | <applet_tag>
    #    ]
    def begin_import(source_name, username = nil, password = nil, user_id = '', redirect_url = nil, opts = {})
      id = nil
      consent_url = nil
      applet_tag = nil
      @options.update(opts)

      # look at the given service and decide how which begin function to invoke.
      unless username.nil? || username.empty?
        resp = begin_import_username_password(source_name, username, password, user_id)
        consent_url = resp['url'] if resp['url']
      else
        unless (source_name =~ /OUTLOOK/i || source_name =~ /ADDRESSBOOK/i).nil?
          resp = begin_import_applet(source_name, user_id)
          applet_tag = create_applet_tag(resp['id'], resp['url'])
        else
          resp = begin_import_consent(source_name, user_id, redirect_url)
          consent_url = resp['url'] if resp['url']
        end
      end

      @import_id = resp['import_id']

      {:import_id => resp['import_id'], :consent_url => consent_url, :applet_tag => applet_tag}
    end

    # returns an array of Cloudsponge::Events with any new event or nil if no new events are available
    def get_events(import_id = nil)
      import_id ||= @import_id
      
      # call to CloudSponge.com for the latest event status and return it
      # create the appropriate url to fetch the contacts
      full_url = generate_poll_url(EVENTS_PATH, import_id)

      # get the response from the server and decode it
      resp = Utility.get_and_decode_response(full_url, auth)
      # interpret the result
      Event.from_array(resp['events'])
    end

    # call to CloudSponge.com for the contacts,
    # returns nil (not ready)
    # or [an array of Contacts, the contacts_owner record]
    def get_contacts(import_id = nil)
      import_id ||= @import_id
      contacts = nil
      if resp = get_contacts_raw(import_id)
        # decode the contacts for consumption
        contacts = Contact.from_array(resp['contacts'])
        contacts_owner = Contact.new(resp['contacts_owner']) rescue nil
      end
      [contacts, contacts_owner]
    end

    # call to CloudSponge.com for the contacts,
    # returns nil (not ready)
    # or a hashmap of contact data
    def get_contacts_raw(import_id)
      resp = nil

      # get the response from the server and decode it
      begin
        resp = Utility.get_and_decode_response(generate_poll_url(CONTACTS_PATH, import_id), auth)
      rescue CsException => e
        raise e unless e.code == 404
      end

      resp
    end
  
  private
  
    # invokes the begin import action for the user consent process.
    #   returns the URL of the consent page that the user must use to sign in and grant consent
    #   throws an exception if an invalid service is invoked.
    def begin_import_consent(source_name, user_id = nil, redirect_url = nil)
      # we need to pass in all params to the call
      params = {:service => source_name, :user_id => user_id, :redirect_url => redirect_url, :include => @options["include"]}.reject{ |_,v| v.nil? || v.empty? }

      # get and decode the response into an associated array
      # Throws an exception if there was a problem at the server
      Utility.post_and_decode_response(full_url(CONSENT_PATH), params, auth)
    end

    # invokes the begin import action for the desktop applet import process.
    # returns the URL of the applet that should be displayed to the user within the appropriate applet tag
    # throws an exception if an invalid service is invoked.
    def begin_import_applet(source_name, user_id = nil)
      # we need to pass in all params to the call
      params = {:service => source_name, :user_id => user_id, :include => @options["include"]}.reject{ |_,v| v.nil? || v.empty? }

      # get and decode the response into an associated array
      # Throws an exception if there was a problem at the server
      Utility.post_and_decode_response(full_url(APPLET_PATH), params, auth)
    end

    # invokes the begin import action for the desktop applet import process.
    # returns the URL of the applet that should be displayed to the user within the appropriate applet tag
    # throws an exception if an invalid service is invoked.
    def begin_import_username_password(source_name, username, password, user_id)
      # we need to pass in all params to the call
      params = {:service => source_name, :user_id => user_id, :username => username, :password => password, :include => @options["include"]}.reject{ |_,v| v.nil? || v.empty? }

      # get and decode the response into an associated array
      # Throws an exception if there was a problem at the server
      Utility.post_and_decode_response(full_url(IMPORT_PATH), params, auth)
    end
    
    def full_url(path)
      "#{URL_BASE}#{BEGIN_PATH}#{path}"
    end

    def authenticated_params(params = {})
      # append domain_key, domain_password to params and serialze into a query string
      params.merge({:domain_key => self.key, :domain_password => self.password})
    end

    def auth
      {:domain_key => self.key, :domain_password => self.password}
    end

    def authenticated_query(params = {})
      # append domain_key, domain_password to params and serialze into a query string
      Utility.object_to_query(params)
    end

    def create_applet_tag(id, url)
      <<-EOS
  <!--[if !IE]> Firefox and others will use outer object -->
    <object classid="java:ContactsApplet" type="application/x-java-applet" archive="#{url}" height="1" width="1" >
      <!-- Konqueror browser needs the following param -->
      <param name="archive" value="#{url}" />
      <param name="cookieValue" value="document.cookie"/>
      <param name="importId" value="#{id}"/>
      <!--<![endif]-->
      <!-- MSIE (Microsoft Internet Explorer) will use inner object --> 
      <object classid="clsid:8AD9C840-044E-11D1-B3E9-00805F499D93" 
              codebase="http://java.sun.com/update/1.5.0/jinstall-1_5_0-windows-i586.cab"
              height="0" width="0" > 
        <param name="code" value="ContactsApplet" />
        <param name="archive" value="#{url}" />
        <param name="cookieValue" value="document.cookie"/>
        <param name="importId" value="#{id}"/>  <strong>
          This browser does not have a Java Plug-in.
          <br />
          <a href="http://java.sun.com/products/plugin/downloads/index.html">
            Get the latest Java Plug-in here.
          </a>
        </strong>
      </object> 
    <!--[if !IE]> close outer object -->
    </object>
  <!--<![endif]-->
  EOS
  #     <<-EOS
  # <APPLET archive="#{url}" code="ContactsApplet" id="Contact_Importer" width="0" height="0">
  #   <PARAM name="cookieValue" value="document.cookie"/>
  #   <PARAM name="importId" value="#{id}"/>
  #   Your browser does not support Java which is required for this utility to operate correctly.
  # </APPLET>
  # EOS
    end

    def generate_poll_url(path, import_id)
      _nonce = Time.now.to_i
      # get the query_string with authentication params and assemble the full url
      "#{URL_BASE}#{path}#{import_id}?_=#{_nonce}&#{authenticated_query}"
    end
  
  end
end






  

