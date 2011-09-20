require 'test/test_helper'

class TestContactImporter < Test::Unit::TestCase
  def test_version_exists
    assert Cloudsponge::VERSION
  end
  
  DOMAIN_KEY = "Your Domain Key"
  DOMAIN_PASSWORD = "Your Domain Password"
  
  def test_u_p_import
    importer = Cloudsponge::ContactImporter.new(DOMAIN_KEY, DOMAIN_PASSWORD)
    importer.begin_import('AOL', 'u', 'p')
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
    importer.begin_import('AOL', 'u', 'p')
    contacts = events_wait(importer)
    assert contacts[0].detect{ |contact| contact.addresses }
  end
  
  private
  
  def events_wait(importer)
    contacts = nil
    loop do
      events = importer.get_events
      break unless events.select{ |e| e.is_error? }.empty?
      unless events.select{ |e| e.is_complete? }.empty?
        contacts = importer.get_contacts
        break
      end
      sleep 1
    end
    contacts
  end
end
