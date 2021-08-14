# frozen_string_literal: true

module Authorio
  class User < ApplicationRecord
    has_secure_password

    def self.find_by_url!(url)
      find_by(profile_path: URI(url || '/').path) or raise Exceptions::UserNotFound
    end

    def profile
      {
        name: full_name,
        url: url,
        photo: photo,
        email: email
      }
    end
  end
end
