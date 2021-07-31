module Authorio
  class User < ApplicationRecord
    has_secure_password

    def self.find_by_url!(url)
      find_by! profile_path: URI(url || "/").path
    end

  end
end
