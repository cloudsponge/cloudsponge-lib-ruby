# -*- encoding: utf-8 -*-
require File.expand_path("../lib/cloudsponge/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "cloudsponge"
  s.version     = Cloudsponge::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Graeme Rouse"]
  s.email       = ["graeme@cloudsponge.com"]
  s.homepage    = "http://rubygems.org/gems/cloudsponge"
  s.summary     = "CloudSponge integration library for Ruby"
  s.description = "CloudSponge is the tool that you need to go viral. Create an account at http://www.cloudsponge.com and integrate with this library. In a few lines of code you'll have access to your users' contact lists."

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "cloudsponge"

  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "ruby-debug", ">= 0.10.3"
  s.add_dependency "json", ">=1.6.1"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
