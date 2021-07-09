module Authorio
  require 'uri'

  class AuthController < ActionController::Base
    def authorization_interface
      p = auth_req_params

      path = if p[:me]
        URI(p[:me]).path
      else
        '/'
      end

      user = User.find_by! profile_path: path
      @user_url = p[:me] || "#{request.scheme}://#{request.host_with_port}#{user.profile_path}"

      # If there are any old requests from this (client, user), delete them now
      Request.where(authorio_user: user, client: p[:client_id]).delete_all

      auth_request = Request.new.tap do |req|
        req.code = p[:code_challenge]
        req.redirect_uri = p[:redirect_uri]
        req.client = p[:client_id] # IndieAuth client_id conflicts with Rails' _id foreign key convention
        req.scope = p[:scope]
        req.authorio_user = user
      end
      auth_request.save
      session[:state] = p[:state]
    end

    def authorize_user
      p = auth_user_params
      user = User.find_by! profile_path: URI(p[:url]).path
      auth_req = Request.find_by! client: p[:client], authorio_user: user
      if user.authenticate(p[:password])
        redirect_to auth_req.redirect_uri, code: auth_req.code, state: session[:state]
      else
        flash.now[:alert] = "Incorrect password. Try again."
        redirect_back fallback_location: Authorio.authorization_path, allow_other_host: false
      end
    end

    private

    def auth_req_params
      %w(client_id redirect_uri state code_challenge).each do |param|
        unless params.key?(param) && !params[param].empty?
          raise ::ActionController::ParameterMissing.new(param)
        end
      end
      params.permit(:response_type, :code_challenge, :code_challenge_method, :scope, :me, :redirect_uri, :client_id, :state)
    end

    def auth_user_params
      params.permit(:password, :url, :client)
    end
  end
end
