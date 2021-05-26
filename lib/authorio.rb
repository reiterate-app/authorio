require "authorio/version"
require "authorio/engine"
require "authorio/configuration"

module Authorio
	class << self
		attr_accessor :configuration
	end

	def self.configuration
		@configuration ||= Configuration.new
 	end

  	def self.configure
		yield configuration
	end
end
