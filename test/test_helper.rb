require 'test/unit'
require 'cloudsponge'
require 'vcr'

DOMAIN_KEY = "DOMAIN_KEY"
DOMAIN_PASSWORD = "DOMAIN_PASSWORD"

PLAXO = {:user => 'u', :password => 'p'}

VCR.configure do |config|
  config.cassette_library_dir = "test/vcr_cassettes"
  config.hook_into :webmock
end
