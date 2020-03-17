# -*- encoding: utf-8 -*-
require File.expand_path("../lib/cloudsponge/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "cloudsponge"
  s.version     = Cloudsponge::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Graeme Rouse"]
  s.email       = ["graeme@cloudsponge.com"]
  s.homepage    = "http://www.cloudsponge.com"
  s.summary     = "CloudSponge integration library for Ruby"
  s.description = "CloudSponge is the tool that you need to go viral. Create an account at http://www.cloudsponge.com and integrate with this library. In a few lines of code you'll have access to your users' contact lists."

  s.required_rubygems_version = ">= 1.3.6"
  s.add_dependency "json", ">=1.6.1"
  s.add_development_dependency "rake"
  s.add_development_dependency "test-unit"
  s.add_development_dependency "vcr"
  s.add_development_dependency "webmock"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
