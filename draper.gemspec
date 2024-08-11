# frozen_string_literal: true

require_relative "lib/draper/version"

Gem::Specification.new do |s|
  s.name        = "draper"
  s.version     = Draper::VERSION::STRING
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Nicolas Rodriguez"]
  s.email       = ["nico@nicoladmin.fr"]
  s.homepage    = "http://github.com/jbox-web/draper"
  s.summary     = "View Models for Rails"
  s.description = "Draper adds an object-oriented layer of presentation logic to your Rails apps."
  s.license     = "MIT"

  s.required_ruby_version = ">= 3.1.0"

  s.files = `git ls-files`.split("\n")

  s.add_dependency "rails", ">= 7.0"
  s.add_dependency "request_store", ">= 1.0"
  s.add_dependency "zeitwerk"
end
