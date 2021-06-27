module Authorio
  class User < ApplicationRecord
    has_secure_password
  end
end
