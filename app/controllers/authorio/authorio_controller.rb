# frozen_string_literal: true

module Authorio
  class AuthorioController < ActionController::Base
    layout 'authorio/main'

    helper_method :logged_in?, :rememberable?, :current_user,
                  :user_scope_description, :profile_url

    def index
      if logged_in?
        redirect_to edit_user_path(current_user)
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

    def user_scope_description(scope)
      Authorio::Request.user_scope_description(scope)
    end

    def profile_url(user)
      verify_user_url(user)
    end

    protected

    def auth_user_params
      params.require(:user).permit(:username, :password, :remember_me)
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

    def bearer_token
      bearer = /^Bearer /
      header = request.headers['Authorization']
      header.gsub(bearer, '') if header&.match(bearer)
    end
  end
end
