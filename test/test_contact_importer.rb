require 'test_helper'

class TestContactImporter < Test::Unit::TestCase
  def test_version_exists
    assert Cloudsponge::VERSION
  end

  def test_u_p_import
    VCR.use_cassette("u_p_import", :match_requests_on => [:method, :host, :path]) do
      importer = Cloudsponge::ContactImporter.new(DOMAIN_KEY, DOMAIN_PASSWORD)
      importer.begin_import('PLAXO', PLAXO[:user], PLAXO[:password])
      contacts = events_wait(importer)
      assert contacts
    end
  end

  def test_aol_import
    VCR.use_cassette("aol_import", :match_requests_on => [:method, :host, :path]) do
      importer = Cloudsponge::ContactImporter.new(DOMAIN_KEY, DOMAIN_PASSWORD)
      resp = importer.begin_import('AOL')
      if ENV['request_consent'] && resp[:consent_url]
        puts "Navigate to #{resp[:consent_url]} and complete the authentication process."
        `open '#{resp[:consent_url]}'`
      end
      contacts = events_wait(importer)
      assert contacts
    end
  end

  def test_wl_import
    VCR.use_cassette("wl_import", :match_requests_on => [:method, :host, :path]) do
      importer = Cloudsponge::ContactImporter.new(DOMAIN_KEY, DOMAIN_PASSWORD)
      resp = importer.begin_import('WINDOWSLIVE')
      if ENV['request_consent'] && resp[:consent_url]
        puts "Navigate to #{resp[:consent_url]} and complete the authentication process."
        `open '#{resp[:consent_url]}'`
      end
      contacts = events_wait(importer)
      assert contacts
    end
  end

  def test_auth_import
    VCR.use_cassette("wl_import", :match_requests_on => [:method, :host, :path]) do
      importer = Cloudsponge::ContactImporter.new(DOMAIN_KEY, DOMAIN_PASSWORD)
      resp = importer.begin_import('YAHOO')
      if ENV['request_consent'] && resp[:consent_url]
        puts "Navigate to #{resp[:consent_url]} and complete the authentication process."
        `open '#{resp[:consent_url]}'`
      end
      contacts = events_wait(importer)
      assert contacts
    end
  end

  def test_contacts_with_mailing_addresses
    VCR.use_cassette("contacts_with_mailing_addresses", :match_requests_on => [:method, :host, :path]) do
      importer = Cloudsponge::ContactImporter.new(DOMAIN_KEY, DOMAIN_PASSWORD, nil, {"include" => "mailing_address"})
      resp = importer.begin_import('AOL')
      if ENV['request_consent'] && resp[:consent_url]
        puts "Navigate to #{resp[:consent_url]} and complete the authentication process."
        `open '#{resp[:consent_url]}'`
      end
      contacts = events_wait(importer)
      assert contacts
      assert contacts[0].detect{ |contact| contact.addresses.any? }
    end
  end

  private

  def events_wait(importer)
    loop do
      events = importer.get_events
      break unless events.select{ |e| e.is_error? }.empty?
      unless events.select{ |e| e.is_complete? }.empty?
        return importer.get_contacts
      end
      sleep 1
    end
    nil
  end
end
