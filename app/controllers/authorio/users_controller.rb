# frozen_string_literal: true

module Authorio
  class UsersController < AuthorioController
    before_action :authorized?, except: :verify

    # GET /users/:id
    def show
      @user = User.find(params[:id])
    end

    # GET /users/:id/edit
    def edit
      @user = User.find(params[:id])
    end

    # PATCH /users/:id
    def update
      User.find(params[:id]).update(user_params)
      flash[:info] = 'Profile Saved'
      redirect_to edit_user_path
    end

    # This is only called by IndieAuth clients who wish to verify that a
    # user profile URL we generated is in fact ours.
    def verify; end

    private

    def user_params
      params.require(:user).permit(:url, :photo, :full_name, :email)
    end
  end
end
