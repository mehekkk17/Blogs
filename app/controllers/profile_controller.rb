# frozen_string_literal: true

class ProfileController < ApplicationController
  before_action :require_login

  def show
    @user = current_user
    @posts = current_user.posts.order(created_at: :desc)
  end

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update(profile_params)
      redirect_to profile_path, notice: "Profile updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:name, :password, :password_confirmation)
  end
end
