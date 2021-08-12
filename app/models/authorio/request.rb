module Authorio
  class Request < ApplicationRecord
    belongs_to :authorio_user, class_name: "::Authorio::User"

    validates_presence_of :code, :redirect_uri, :client

    before_validation :set_code, on: :create
    before_create :sweep_requests

    # User has the right to modify requested scope
    def update_scope(scope)
      update(scope: scope.join(' '))
    end

    # The IndieAuth spec uses 'client_id' to specify the client in the address, as a URL (eg "https://example.com")
    # But Rails uses '_id' to tag associations (foreign keys). So we save that as 'client' here, but map
    # client_id as an alias since that is what the HTTP parameter will be
    def client_id=(value)
      self.client=value
    end

    def invalid?(params)
      redirect_uri != params[:redirect_uri] ||
      client != params[:client_id] ||
      created_at < Time.now - 10.minutes
    end

    def profile
      scopes = scope&.split
      user_profile = { me: authorio_user.profile_path }
      if scopes&.include? 'profile'
        user_profile[:profile] = {
          name: authorio_user.full_name,
          url: authorio_user.url,
          photo: authorio_user.photo,
          email: (authorio_user.email if scopes.include? 'email')
        }.compact
      end
      user_profile
    end

    private

    def set_code
      self.code = SecureRandom.hex(20)
    end

    def sweep_requests
      Request.where(client: client, authorio_user: authorio_user).destroy_all
    end
  end
end
