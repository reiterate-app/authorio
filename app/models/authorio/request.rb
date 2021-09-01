# frozen_string_literal: true

module Authorio
  class Request < ApplicationRecord
    belongs_to :authorio_user, class_name: '::Authorio::User'

    validates_presence_of :code, :redirect_uri, :client

    before_validation :set_code, on: :create
    before_create :sweep_requests

    # The IndieAuth spec uses 'client_id' to specify the client in the address, as a URL (eg "https://example.com")
    # But Rails uses '_id' to tag associations (foreign keys). So we save that as 'client' here, but map
    # client_id as an alias since that is what the HTTP parameter will be
    def client_id=(value)
      self.client = value
    end

    def validate_oauth(params)
      redirect_uri == params[:redirect_uri] &&
        client == params[:client_id] &&
        created_at > Time.now - 10.minutes &&
        code_challenge_matches(params[:code_verifier]) &&
        self
    end

    def code_challenge_matches(verifier)
      # For now, if original request did not have code challenge, then we pass by default
      return true if code_challenge.blank?

      sha256 = Digest::SHA256.digest verifier
      Base64.urlsafe_encode64(sha256).sub(/=*$/, '') == code_challenge
    end

    def self.user_scope_description(scope)
      USER_SCOPE_DESCRIPTION[scope.to_sym] || scope
    end

    private

    def set_code
      self.code = SecureRandom.hex(20)
    end

    def sweep_requests
      Request.where(client: client, authorio_user: authorio_user).destroy_all
    end

    USER_SCOPE_DESCRIPTION = {
      profile: 'View basic profile information',
      email: 'View your email address'
    }.freeze
  end
end
