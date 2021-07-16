module Authorio
  # These helpers are provided to the main application
  module TagHelper
    extend ActiveSupport::Concern

    included do
      if respond_to?(:helper_method)
        helper_method :indieauth_tag
      end
    end

    def indieauth_tag
      tag(:link, rel: 'authorization_endpoint', href: URI.join(root_url, Authorio.authorization_path)) <<
      tag(:link, rel: 'token_endpoint', href: URI.join(root_url, Authorio.token_path))
    end
  end
end
