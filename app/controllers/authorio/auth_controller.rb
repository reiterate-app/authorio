module Authorio
  class AuthController < ActionController::Base
    require 'uri'
    require 'digest'

    def authorization_interface
      p = auth_req_params

      path = if p[:me]
        URI(p[:me]).path
      else
        '/'
      end

      user = User.find_by! profile_path: path
      @user_url = p[:me] || user_url(user)

      # If there are any old requests from this (client, user), delete them now
      Request.where(authorio_user: user, client: p[:client_id]).delete_all

      auth_request = Request.new.tap do |req|
        req.code = SecureRandom.hex(20)
        req.redirect_uri = p[:redirect_uri]
        req.client = p[:client_id] # IndieAuth client_id conflicts with Rails' _id foreign key convention
        req.scope = p[:scope]
        req.authorio_user = user
      end
      auth_request.save
      session[:state] = p[:state]
      session[:code_challenge] = p[:code_challenge]
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

    def send_profile
      begin
        render json: { 'me': user_url(validate_request.authorio_user) }
      rescue Authorio::Exceptions::InvalidGrant
        render invalid_grant
      end
    end

    def issue_token
      begin
        req = validate_request
        raise Authorio::Exceptions::InvalidGrant.new if req.scope.blank?
        token = Token.create(authorio_user: req.authorio_user, scope: req.scope, client: req.client)
        render json: {
          'me': user_url(req.authorio_user),
          'access_token': token.auth_token,
          'scope': req.scope,
          'token_type': 'Bearer'
        }
      rescue Authorio::Exceptions::InvalidGrant
        render invalid_grant
      end
    end

    def verify_token
      token = Token.find_by auth_token: bearer_token
      head :bad_request and return if token.nil?
      render json: {
        'me': user_url(token.authorio_user),
        'client_id': token.client,
        'scope': 'token.scope'
      }
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

    def user_url(user)
      "#{request.scheme}://#{request.host}#{user.profile_path}"
    end

    def invalid_grant
      { json: { 'error': 'invalid_grant' }, status: :bad_request }
    end

    def code_challenge_failed?
      # For now, if original request did not have code challenge, then we pass by default
      return false if session[:code_challenge].nil?
      sha256 = Digest::SHA256.hexdigest params[:code_verifier]
      base64 = Base64.urlsafe_encode64 sha256
      return base64 != session[:code_challenge]
    end

    def invalid_request?(req)
      req.redirect_uri != params[:redirect_uri] \
        || req.client != params[:client_id] \
        || req.created_at < Time.now - 10.minutes
    end

    def validate_request
      req = Request.find_by code: params[:code]
      raise Authorio::Exceptions::InvalidGrant.new if req.nil?
      req.delete
      raise Authorio::Exceptions::InvalidGrant.new if invalid_request?(req) || code_challenge_failed?
      req
    end

    def bearer_token
      bearer = /^Bearer /
      header = request.headers['Authorization']
      header.gsub(bearer, '') if header && header.match(bearer)
    end

  end
end
