# frozen_string_literal: true

# Configuration for Authorio IndieAuth authentication

Authorio.configure do |config|
  # Mount point for Authorio URLs. Typically you would call this in your routes.rb
  # as mount Authorio::Engine, at: mount_point
  # But Authorio needs to know its own mount point, so we define it here and use a custom mount command in the config
  # config.mount_point = "authorio"

  # The path where clients will be redirected to provide authentication
  # config.authorization_endpoint = "auth"

  # The path for token requests
  # config.token_endpoint = "token"

  # Set to true to enable multiple user accounts. By default (in single user mode)
  # there is only one user, and therefore you do not need to enter a username
  # config.multiuser = false

  # How long tokens will last before expiring
  # config.token_expiration = 4.weeks

  # Enable local session lifetime to keep yourself "logged in" to your own server
  # If set to eg:
  #  config.local_session_lifetime = 30.days
  # then you will only have to enter your password every 30 days. Default is off (nil)
  # config.local_session_lifetime = nil
end
