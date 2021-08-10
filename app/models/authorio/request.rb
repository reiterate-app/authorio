module Authorio
  class Request < ApplicationRecord
    belongs_to :authorio_user, class_name: "::Authorio::User"

    validates_presence_of :code, :redirect_uri, :client

    before_validation :set_code, on: :create

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

    private

    def set_code
      self.code = SecureRandom.hex(20)
    end
  end
end
