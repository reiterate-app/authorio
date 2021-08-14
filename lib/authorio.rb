# frozen_string_literal: true

Dir[File.join(__dir__, 'authorio', '*.rb')].sort.each { |f| require f }

module Authorio
  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield configuration
  end

  def self.authorization_path
    [Authorio.configuration.mount_point, Authorio.configuration.authorization_endpoint].join('/')
  end

  def self.token_path
    [Authorio.configuration.mount_point, Authorio.configuration.token_endpoint].join('/')
  end
end
