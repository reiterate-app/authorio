# frozen_string_literal: true

json.access_token @token.auth_token
json.expires_in Authorio.configuration.token_expiration
json.token_type 'Bearer'
json.scope @token.scope
json.partial! 'authorio/users/profile', request: @request
