module Authorio
  require 'uri'

  class AuthController < ActionController::Base
    def authorization_interface
      p = auth_params

      path = if p[:me]
        URI(p[:me]).path
      else
        '/'
      end
      user = User.find_by! profile_path: path

      auth_request = Request.new.tap do |req|
        req.code = p[:code_challenge]
        req.redirect_uri = p[:redirect_uri]
        req.client = p[:client_id] # IndieAuth client_id conflicts with Rails' _id foreign key convention
        req.scope = p[:scope]
        req.authorio_user = user
      end
      auth_request.save
    end

    private

    def auth_params
      %w(client_id redirect_uri state code_challenge).each do |param|
        unless params.key?(param) && !params[param].empty?
          raise ::ActionController::ParameterMissing.new(param)
        end
      end
      params.permit(:response_type, :code_challenge, :code_challenge_method, :scope, :me, :redirect_uri, :client_id, :state)
    end
  end
end
