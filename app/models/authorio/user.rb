# frozen_string_literal: true

module Authorio
  class User < ApplicationRecord
    has_secure_password

    class << self
      def find_by_url!(url)
        find_by_username!(URI(url).path)
      end

      def find_by_username!(name)
        return first unless Authorio.configuration.multiuser

        find_by(username: name) or raise Exceptions::UserNotFound
      end
    end
  end
end
