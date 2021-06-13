require "authorio/version"
require "authorio/engine"
require "authorio/configuration"
require "authorio/routes"

module Authorio
	class << self
		attr_accessor :configuration, :authorization_path
	end

	def self.configuration
		@configuration ||= Configuration.new
 	end

  	def self.configure
		yield configuration
	end

	def self.authorization_path
		return [Authorio.configuration.mount_point, Authorio.configuration.authorization_endpoint].join("/")
	end
end
