module Authorio
  # Those helpers are convenience methods added to ApplicationController.
  module Helpers
    extend ActiveSupport::Concern

    included do
      if respond_to?(:helper_method)
        helper_method :indieauth_tag
      end
    end

    def indieauth_tag
      %Q[<link rel="authorization_endpoint" href="#{authorization_uri}">].html_safe
    end


    private

    def authorization_uri
      URI.join(root_url, Authorio.configuration.authorization_endpoint)
    end
  end
end
