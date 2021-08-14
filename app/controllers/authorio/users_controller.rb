# frozen_string_literal: true

module Authorio
  class UsersController < AuthorioController
    before_action :authorized?

    # GET   /users/:id/edit
    def edit
      @user = User.find(params[:id])
    end

    # PATCH /users/:id
    def update
      User.find(params[:id]).update(user_params)
      flash[:info] = 'Profile Saved'
      redirect_to edit_user_path
    end

    private

    def user_params
      params.require(:user).permit(:url, :photo, :full_name, :email)
    end
  end
end
