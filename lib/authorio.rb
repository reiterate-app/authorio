# frozen_string_literal: true

require 'authorio/version'
require 'authorio/engine'
require 'authorio/configuration'
require 'authorio/routes'
require 'authorio/exceptions'

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
