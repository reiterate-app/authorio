# frozen_string_literal: true

module Authorio
  # These helpers are provided to the main application
  module TagHelper
    extend ActiveSupport::Concern

    included do
      helper_method :indieauth_tag if respond_to?(:helper_method)
    end

    def indieauth_tag
      tag(:link, rel: 'authorization_endpoint', href: app_root_path(Authorio.authorization_path)) <<
        tag(:link, rel: 'token_endpoint', href: app_root_path(Authorio.token_path))
    end

    private

    def app_root_path(path)
      URI.join(main_app.root_url, path)
    rescue URI::InvalidURIError
      '#'
    end
  end
end
