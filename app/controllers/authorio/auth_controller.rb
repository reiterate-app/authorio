module Authorio
  class AuthController < ActionController::Base
    require 'uri'
    require 'digest'
    layout 'authorio/main'

    # These API-only endpoints are protected by code challenge and do not need CSRF protextion
    protect_from_forgery with: :exception, except: [:send_profile, :issue_token]

    rescue_from 'Authorio::Exceptions::SessionReplayAttack' do |exception|
      redirect_back_with_error "Session Replay attack detected. This has been logged."
      logger.info "Session replay attack detected!"
      Authorio::Session.where(user: exception.session.user).delete_all
    end

    # GET /auth
    def authorization_interface
      %w(client_id redirect_uri state code_challenge).each do |param|
        raise ::ActionController::ParameterMissing, param unless params[param].present?
      end
      @user = User.find_by_url! params[:me]

      # If there are any old requests from this (client, user), delete them now
      Request.where(authorio_user: @user, client: params[:client_id]).delete_all

      auth_request = Request.create(
        code: SecureRandom.hex(20),
        redirect_uri: params[:redirect_uri],
        client: params[:client_id], # IndieAuth client_id conflicts with Rails' _id foreign key convention
        scope: params[:scope],
        authorio_user: @user
        )
      session.update request.parameters.slice(*%w(state client_id code_challenge))
      @user_logged_in_locally = !user_session.nil?
      @rememberable = Authorio.configuration.local_session_lifetime && !@user_logged_in_locally
    rescue ActiveRecord::RecordNotFound
      redirect_back_with_error "Invalid user"
    end

    # POST /user/:id/authorize
    def authorize_user
      redirect_to session[:client_id] and return if params[:commit] == "Cancel"

      user = authenticate_user_from_session_or_password
      if auth_user_params[:remember_me]
        cookies.encrypted[:user] = {
          value: Authorio::Session.create(authorio_user: user).as_cookie,
          expires: Authorio.configuration.local_session_lifetime
        }
      end

      auth_req = Request.find_by! client: session[:client_id], authorio_user: user
      redirect_params = { code: auth_req.code, state: session[:state] }
      redirect_to "#{auth_req.redirect_uri}?#{redirect_params.to_query}"
    rescue ActiveRecord::RecordNotFound
      redirect_back_with_error "Invalid user"
    rescue Authorio::Exceptions::InvalidPassword
      redirect_back_with_error "Incorrect password. Try again."
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

    def user_session
      cookie = cookies.encrypted[:user] and Session.find_by_cookie(cookie)
    end

    def redirect_back_with_error(error)
      flash[:alert] = error
      redirect_back fallback_location: Authorio.authorization_path, allow_other_host: false
    end

    def authenticate_user_from_session_or_password
      session = user_session
      if session
        return session.authorio_user
      else
        user = User.find_by! profile_path: URI(auth_user_params[:url]).path
        raise Authorio::Exceptions::InvalidPassword unless user.authenticate(auth_user_params[:password])
        return user
      end
    end

  end
end
