module Authorio
  class Token < ApplicationRecord
    belongs_to :authorio_user, class_name: "::Authorio::User"
    has_secure_token :auth_token

    validates_presence_of :scope, :client
  end
end
