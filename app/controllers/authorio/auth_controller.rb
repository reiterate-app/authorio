module Authorio
  class AuthController < ActionController::Base
    require 'uri'
    require 'digest'
    layout 'authorio/main'

    # These API-only endpoints are protected by code challenge and do not need CSRF protextion
    protect_from_forgery with: :exception, except: [:send_profile, :issue_token]

    def authorization_interface
      p = auth_req_params
      p[:me] ||= "#{host_with_protocol}/"
      @user = User.find_by! profile_path: URI(p[:me]).path

      # If there are any old requests from this (client, user), delete them now
      Request.where(authorio_user: @user, client: p[:client_id]).delete_all

      auth_request = Request.new.tap do |req|
        req.code = SecureRandom.hex(20)
        req.redirect_uri = p[:redirect_uri]
        req.client = p[:client_id] # IndieAuth client_id conflicts with Rails' _id foreign key convention
        req.scope = p[:scope]
        req.authorio_user = @user
      end
      auth_request.save
      session[:state] = p[:state]
      session[:code_challenge] = p[:code_challenge]
      session[:client_id] = p[:client_id]
      @user_logged_in_locally = user_session_valid?(@user.profile_path)
      @rememberable = Authorio.configuration.local_session_lifetime && !user_session_valid?(@user.profile_path)

    rescue ActiveRecord::RecordNotFound
      flash[:alert] = "Invalid user"
      redirect_back fallback_location: Authorio.authorization_path, allow_other_host: false
    end

    def authorize_user
      p = auth_user_params

      if params[:commit] == "Cancel"
        redirect_to session[:client_id] and return
      end

      user = User.find_by! profile_path: URI(p[:url]).path
      auth_req = Request.find_by! client: session[:client_id], authorio_user: user
      if user_session_valid?(user.profile_path) || user.authenticate(p[:password])
        if Authorio.configuration.local_session_lifetime && !user_session_valid?(user.profile_path) && p[:remember_me]
          cookies.encrypted[:user_path] = { value: user.profile_path, expires: Authorio.configuration.local_session_lifetime }
        end
        params = { code: auth_req.code, state: session[:state] }
        redirect_to "#{auth_req.redirect_uri}?#{params.to_query}"
      else
        flash.now[:alert] = "Incorrect password. Try again."
        redirect_back fallback_location: Authorio.authorization_path, allow_other_host: false
      end
    rescue ActiveRecord::RecordNotFound
      flash.now[:alert] = "Invalid user"
      redirect_back fallback_location: Authorio.authorization_path, allow_other_host: false
    end

    def send_profile
      render json: { 'me': user_url(validate_request.authorio_user) }
    rescue Authorio::Exceptions::InvalidGrant
      render invalid_grant
    end

    def issue_token
      req = validate_request
      raise Authorio::Exceptions::InvalidGrant.new if req.scope.blank?
      token = Token.create(authorio_user: req.authorio_user, scope: req.scope, client: req.client)
      render json: {
        'me': user_url(req.authorio_user),
        'access_token': token.auth_token,
        'scope': req.scope,
        'expires_in': Authorio.configuration.token_expiration,
        'token_type': 'Bearer'
      }
    rescue Authorio::Exceptions::InvalidGrant
      render invalid_grant
    end

    def verify_token
      token = Token.find_by! auth_token: bearer_token
      if token.expired?
        token.delete
        render token_expired
      else
        render json: {
          'me': user_url(token.authorio_user),
          'client_id': token.client,
          'scope': 'token.scope'
        }
      end
    rescue ActiveRecord::RecordNotFound
      head :bad_request
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
      params.require(:user).permit(:password, :url, :remember_me)
    end

    def host_with_protocol
      "#{request.scheme}://#{request.host}"
    end

    def user_url(user)
      "#{host_with_protocol}#{user.profile_path}"
    end

    def invalid_grant
      { json: { 'error': 'invalid_grant' }, status: :bad_request }
    end

    def token_expired
      { json: {'error': 'invalid_token', 'error_message': 'The access token has expired' }, status: :unauthorized }
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

    def user_session_valid?(user_path)
      cookies.encrypted[:user_path] == user_path
    end
  end
end
