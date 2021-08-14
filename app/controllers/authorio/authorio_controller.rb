# frozen_string_literal: true

module Authorio
  class AuthorioController < ActionController::Base
    layout 'authorio/main'

    helper_method :logged_in?, :rememberable?, :user_url, :current_user,
                  :user_scope_description

    def index
      if logged_in?
        redirect_to edit_user_path(1)
      else
        redirect_to new_session_path
      end
    end

    def user_session
      if session[:user_id]
        Session.new(authorio_user: Authorio::User.find(session[:user_id]))
      else
        cookie = cookies.encrypted[:user] and Session.find_by_cookie(cookie)
      end
    end

    def logged_in?
      !user_session.nil?
    end

    def rememberable?
      !logged_in? && Authorio.configuration.local_session_lifetime
    end

    def authorized?
      redirect_to new_session_path unless logged_in?
    end

    def current_user
      user_session&.authorio_user&.id
    end

    def user_url(user)
      "#{host_with_protocol}#{user.profile_path}"
    end

    def user_scope_description(scope)
      Authorio::Request.user_scope_description(scope)
    end

    protected

    def auth_user_params
      params.require(:user).permit(:password, :url, :remember_me)
    end

    def write_session_cookie(user)
      cookies.encrypted[:user] = {
        value: Authorio::Session.create(authorio_user: user).as_cookie,
        expires: Authorio.configuration.local_session_lifetime
      }
    end

    def redirect_back_with_error(error)
      flash[:alert] = error
      redirect_back fallback_location: Authorio.authorization_path.prepend('/'), allow_other_host: false
    end

    def host_with_protocol
      "#{request.scheme}://#{request.host}"
    end

    # IndieAuth users are identified by a full URL, but Model classes are isolated
    # from the hostname and scheme. Here we take the user profile path and upgrade it to a full URL
    def absolute_profile!(json)
      json[:me]&.prepend host_with_protocol if json[:me]&.start_with? '/'
      json
    end

    def bearer_token
      bearer = /^Bearer /
      header = request.headers['Authorization']
      header.gsub(bearer, '') if header&.match(bearer)
    end
  end
end
