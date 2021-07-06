module Authorio
  class Request < ApplicationRecord
    belongs_to :authorio_user, class_name: "::Authorio::User"
    has_secure_token :auth_token

    validates_presence_of :code, :redirect_uri, :client
  end
end
