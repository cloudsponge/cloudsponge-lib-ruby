require 'test/test_helper'

class TestContactImporter < Test::Unit::TestCase
  def test_version_exists
    assert Cloudsponge::VERSION
  end
  
  DOMAIN_KEY = "Domain Key"
  DOMAIN_PASSWORD = "Domain Password"
  
  def test_u_p_import
    importer = Cloudsponge::ContactImporter.new(DOMAIN_KEY, DOMAIN_PASSWORD)
    importer.begin_import('PLAXO', 'u', 'p')
    contacts = events_wait(importer)
    assert contacts
  end

  def test_aol_import
    importer = Cloudsponge::ContactImporter.new(DOMAIN_KEY, DOMAIN_PASSWORD)
    resp = importer.begin_import('AOL', 'u', 'p')
    puts "Navigate to #{resp[:consent_url]} and complete the authentication process." if resp[:consent_url]
    contacts = events_wait(importer)
    assert contacts
  end

  def test_wl_import
    importer = Cloudsponge::ContactImporter.new(DOMAIN_KEY, DOMAIN_PASSWORD)
    resp = importer.begin_import('WINDOWSLIVE')
    puts "Navigate to #{resp[:consent_url]} and complete the authentication process." if resp[:consent_url]
    contacts = events_wait(importer)
    assert contacts
  end
  
  def test_auth_import
    importer = Cloudsponge::ContactImporter.new(DOMAIN_KEY, DOMAIN_PASSWORD)
    resp = importer.begin_import('YAHOO')
    puts "Navigate to #{resp[:consent_url]} and complete the authentication process."
    contacts = events_wait(importer)
    assert contacts
  end
  
  def test_contacts_with_mailing_addresses
    importer = Cloudsponge::ContactImporter.new(DOMAIN_KEY, DOMAIN_PASSWORD, nil, {"include" => "mailing_address"})
    importer.begin_import('PLAXO', 'u', 'p')
    contacts = events_wait(importer)
    assert contacts
    assert contacts[0].detect{ |contact| contact.addresses.any? }
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
