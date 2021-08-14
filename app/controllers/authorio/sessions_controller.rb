# frozen_string_literal: true

module Authorio
  class SessionsController < AuthorioController
    # GET /session/new
    def new
      @session = Session.new(authorio_user: User.first)
    end

    # POST /session
    def create
      user = User.find_by! profile_path: URI(auth_user_params[:url]).path
      raise Exceptions::InvalidPassword unless user.authenticate(auth_user_params[:password])

      write_session_cookie(user) if auth_user_params[:remember_me]
      # Even if we don't have a permanent remember-me session, we make a temporary session
      session[:user_id] = user.id
      redirect_to edit_user_path(user)
    rescue Exceptions::InvalidPassword
      redirect_back_with_error 'Incorrect password. Try again.'
    end

    # DELETE /session
    def destroy
      reset_session
      if (cookie = cookies.encrypted[:user]) && (session = Session.find_by_cookie(cookie))
        cookies.delete :user
        session.destroy
      end
      redirect_to new_session_path
    end
  end
end
