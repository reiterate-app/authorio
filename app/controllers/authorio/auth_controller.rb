module Authorio
  class AuthController < AuthorioController
    require 'uri'
    require 'digest'

    # These API-only endpoints are protected by code challenge and do not need CSRF protextion
    protect_from_forgery with: :exception, except: [:send_profile, :issue_token]

    rescue_from 'Authorio::Exceptions::SessionReplayAttack' do |exception|
      redirect_back_with_error "Session Replay attack detected. This has been logged."
      logger.info "Session replay attack detected!"
      Session.where(user: exception.session.user).delete_all
    end

    helper_method :user_scope_description

    # GET /auth
    def authorization_interface
      %w(client_id redirect_uri state code_challenge).each do |param|
        raise ::ActionController::ParameterMissing, param unless params[param].present?
      end
      @user = User.find_by_url! params[:me]
      Request.create!(request.parameters.slice(:client_id, :redirect_uri, :scope)) { |req|
        req.authorio_user = @user
      }
      session.update request.parameters.slice(:state, :client_id, :code_challenge)
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
    rescue Exceptions::InvalidPassword
      redirect_back_with_error "Incorrect password. Try again."
    end

    def send_profile
      request = validate_request Request.find_by! code: params[:code]
      render json: absolute_profile!(request.profile)
    rescue Exceptions::InvalidGrant, ActiveRecord::RecordNotFound => error
      render oauth_error 'invalid_grant', error.message
    end

    def issue_token
      req = validate_request Request.find_by! code: params[:code]
      token = Token.create_from_request(req)
      render json: token.as_json.merge(absolute_profile! req.profile)
    rescue Exceptions::InvalidGrant, ActiveRecord::RecordNotFound => error
      render oauth_error, 'invalid_grant', error.message
    end

    def verify_token
      token = Token.find_by! auth_token: bearer_token
      if token.expired?
        token.delete
        render token_expired
      else
        render json: absolute_profile!( token.verification_response )
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
      if session[:code_challenge]
        sha256 = Digest::SHA256.hexdigest params[:code_verifier]
        Base64.urlsafe_encode64( sha256 ) != session[:code_challenge]
      end
    end

    def validate_request(request)
      raise Exceptions::InvalidGrant, "validation failed" if request.invalid?(params) || code_challenge_failed?
      request
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
      raise Exceptions::InvalidPassword
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
