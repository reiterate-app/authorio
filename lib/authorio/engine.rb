# frozen_string_literal: true

module Authorio
  class Engine < ::Rails::Engine
    isolate_namespace Authorio

    initializer 'authorio.load_helpers' do
      Rails.application.reloader.to_prepare do
        ActionView::Base.send :include, Authorio::TagHelper
      end
    end

    initializer 'authorio.assets.precompile' do |app|
      app.config.assets.precompile << ['authorio/application.css', 'authorio/auth.css']
    end
  end
end
