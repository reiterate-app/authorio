# frozen_string_literal: true

module Authorio
  class Request < ApplicationRecord
    belongs_to :authorio_user, class_name: '::Authorio::User'

    validates_presence_of :code, :redirect_uri, :client

    before_validation :set_code, on: :create
    before_create :sweep_requests

    def self.find_by_client_and_user!(client, user)
      Request.find_by(client: client, authorio_user: user) or raise Exceptions::UserNotFound
    end

    def self.create_from_user_params(user, params)
      Request.create! do |req|
        req.client = params[:client_id]
        req.redirect_uri = params[:redirect_uri]
        req.scope = params[:scope]
        req.authorio_user = user
      end
    end

    # User has the right to modify requested scope
    def update_scope(scope)
      update(scope: scope.join(' '))
    end

    # The IndieAuth spec uses 'client_id' to specify the client in the address, as a URL (eg "https://example.com")
    # But Rails uses '_id' to tag associations (foreign keys). So we save that as 'client' here, but map
    # client_id as an alias since that is what the HTTP parameter will be
    def client_id=(value)
      self.client = value
    end

    def invalid?(params)
      redirect_uri != params[:redirect_uri] ||
        client != params[:client_id] ||
        created_at < Time.now - 10.minutes
    end

    def profile
      user_profile = { me: authorio_user.profile_path }
      if scope&.include? 'profile'
        profile = authorio_user.profile
        profile.delete :email unless scope.include? 'email'
        user_profile[:profile] = profile
      end
      user_profile
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
      email: 'View your email address',
      offline_access: 'Keep you logged in permanently (until revoked)'
    }.freeze
  end
end
