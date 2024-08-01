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

  s.required_ruby_version = ">= 3.0.0"

  s.files         = `git ls-files`.split("\n")
  s.require_paths = ["lib"]

  s.add_runtime_dependency "rails", ">= 6.1"
  s.add_runtime_dependency "request_store", ">= 1.0"
  s.add_runtime_dependency "zeitwerk"

  s.add_development_dependency "appraisal"
  s.add_development_dependency "capybara"
  s.add_development_dependency "cuprite"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "factory_bot"
  s.add_development_dependency "faker"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "puma"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "rspec-retry"
  s.add_development_dependency "rubocop"
  s.add_development_dependency "rubocop-capybara"
  s.add_development_dependency "rubocop-factory_bot"
  s.add_development_dependency "rubocop-rake"
  s.add_development_dependency "rubocop-rspec"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "sqlite3", "~> 1.5.0"

  # rubocop:disable Gemspec/RubyVersionGlobalsUsage
  if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.1.0")
    s.add_development_dependency "net-imap"
    s.add_development_dependency "net-pop"
    s.add_development_dependency "net-smtp"
  end

  if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.4.0")
    s.add_development_dependency "base64"
    s.add_development_dependency "bigdecimal"
    s.add_development_dependency "mutex_m"
    s.add_development_dependency "drb"
    s.add_development_dependency "logger"
  end
  # rubocop:enable Gemspec/RubyVersionGlobalsUsage
end
