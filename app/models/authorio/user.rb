# frozen_string_literal: true

module Authorio
  class User < ApplicationRecord
    has_secure_password

    def self.find_by_url!(url)
      return first unless Authorio.configuration.multiuser

      path = URI(url).path
      find_by(username: path) or raise Exceptions::UserNotFound
    end

    def self.find_by_username!(name)
      return first unless Authorio.configuration.multiuser

      find_by(username: name) or raise Exceptions::UserNotFound
    end
  end
end
