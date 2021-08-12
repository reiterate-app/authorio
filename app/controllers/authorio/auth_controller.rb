module Authorio
  class AuthController < AuthorioController
    require 'uri'
    require 'digest'

    # These API-only endpoints are protected by code challenge and do not need CSRF protextion
    protect_from_forgery with: :exception, except: [:send_profile, :issue_token]

    rescue_from 'Authorio::Exceptions::SessionReplayAttack' do |exception|
      redirect_back_with_error "Session Replay attack detected. This has been logged."
      logger.info "Session replay attack detected!"
      Authorio::Session.where(user: exception.session.user).delete_all
    end

    helper_method :user_scope_description

    # GET /auth
    def authorization_interface
      %w(client_id redirect_uri state code_challenge).each do |param|
        raise ::ActionController::ParameterMissing, param unless params[param].present?
      end
      @user = User.find_by_url! params[:me]

      # If there are any old requests from this (client, user), delete them now
      Request.where(authorio_user: @user, client: params[:client_id]).delete_all

      Request.create!(request.parameters.slice(:client_id, :redirect_uri, :scope)) { |req|
        req.authorio_user = @user
      }
      session.update request.parameters.slice(*%w(state client_id code_challenge))
      @scope = params[:scope]&.split
    rescue ActiveRecord::RecordNotFound
      redirect_back_with_error "Invalid user"
    rescue ActionController::ParameterMissing => error
      render oauth_error "invalid_request", "missing parameter #{error}"
    end

    # POST /user/:id/authorize
    def authorize_user
      redirect_to session[:client_id] and return if params[:commit] == "Cancel"

      user = authenticate_user_from_session_or_password
      set_session_cookie(user) if auth_user_params[:remember_me]

      auth_req = Request.find_by! client: session[:client_id], authorio_user: user
      auth_req.update_scope(scope_params[:scope]) if params.has_key? :scope
      redirect_params = { code: auth_req.code, state: session[:state] }
      redirect_to "#{auth_req.redirect_uri}?#{redirect_params.to_query}"
    rescue ActiveRecord::RecordNotFound
      redirect_back_with_error "Invalid user"
    rescue Authorio::Exceptions::InvalidPassword
      redirect_back_with_error "Incorrect password. Try again."
    end

    def send_profile
      request = validate_request
      render json: profile(request)
    rescue Authorio::Exceptions::InvalidGrant => error
      render oauth_error 'invalid_grant', error.message
    end

    def issue_token
      req = validate_request
      raise Authorio::Exceptions::InvalidGrant, 'missing scope' if req.scope.blank?
      token = Token.create(authorio_user: req.authorio_user, scope: req.scope, client: req.client)
      render json: {
        'access_token': token.auth_token,
        'scope': req.scope,
        'expires_in': Authorio.configuration.token_expiration,
        'token_type': 'Bearer'
      }.merge(profile(req))
    rescue Authorio::Exceptions::InvalidGrant => error
      render oauth_error, 'invalid_grant', error.message
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

    def scope_params
      params.require(:scope).permit(scope: [])
    end

    def oauth_error(error, message=nil, status=:bad_request)
      { json: { json: { error: error, error_message: message }.compact },
        status: status }
    end

    def token_expired
      oauth_error('invalid_token', 'The access token has expired', :unauthorized)
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
      raise Authorio::Exceptions::InvalidGrant, "code not found" if req.nil?
      req.delete
      raise Authorio::Exceptions::InvalidGrant, "validation failed" if invalid_request?(req) || code_challenge_failed?
      req
    end

    def profile(request)
      scopes = request.scope&.split
      { me: user_url(request.authorio_user) }.tap do |profile|
        if scopes&.include? 'profile'
          profile['profile'] = {
            name: request.authorio_user.full_name,
            url: request.authorio_user.url,
            photo: request.authorio_user.photo,
            email: (request.authorio_user.email if scopes.include? 'email')
          }.compact
        end
      end
    end

    def bearer_token
      bearer = /^Bearer /
      header = request.headers['Authorization']
      header.gsub(bearer, '') if header && header.match(bearer)
    end

    def authenticate_user_from_session_or_password
      user_session&.authorio_user or
      User.find_by!( profile_path: URI(auth_user_params[:url]).path ).
        authenticate(auth_user_params[:password]) or
      raise Authorio::Exceptions::InvalidPassword
    end

    ScopeDescriptions = {
      'profile': 'View basic profile information',
      'email': 'View your email address',
      'offline_access': 'Keep you logged in permanently (until revoked)'
    }

    def user_scope_description(scope)
      ScopeDescriptions.dig(scope.to_sym) || scope
    end

  end
end
