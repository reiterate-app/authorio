require_relative "lib/authorio/version"

Gem::Specification.new do |spec|
  spec.name        = "authorio"
  spec.version     = Authorio::VERSION
  spec.authors     = ["Michael Meckler"]
  spec.email       = ["rattroupe@reiterate-app.com"]
  spec.homepage    = "https://rubygems.org/gems/authorio"
  spec.summary     = "Indieauth Authentication endpoint for Rails"
  spec.description = "Rails engine to add IndieAuth authentication endpoiont functionality"
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 6.1.3", ">= 6.1.3.2"
  spec.add_dependency "bcrypt"
  spec.add_development_dependency "factory_bot_rails"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "byebug"
end
