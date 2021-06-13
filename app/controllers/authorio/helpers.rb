module Authorio
  # These helpers are provided to the main application
  module Helpers
    extend ActiveSupport::Concern

    included do
      if respond_to?(:helper_method)
        helper_method :indieauth_tag
      end
    end

    def indieauth_tag
      %Q[<link rel="authorization_endpoint" href="#{URI.join(root_url, Authorio.authorization_path)}">].html_safe
    end
  end
end
