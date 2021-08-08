module Authorio
  class Request < ApplicationRecord
    belongs_to :authorio_user, class_name: "::Authorio::User"

    validates_presence_of :code, :redirect_uri, :client

    # User has the right to modify requested scope
    def update_scope(scope)
      update(scope: scope.join(' '))
    end
  end
end
