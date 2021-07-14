module Authorio
	class Engine < ::Rails::Engine
		isolate_namespace Authorio

		initializer "authorio.load_helpers" do |app|
			Rails.application.reloader.to_prepare do
				ActionController::Base.send :include, Authorio::Helpers
			end
		end

		initializer "authorio.assets.precompile" do |app|
			app.config.assets.precompile += %w( authorio/auth.css )
		end
	end
end
