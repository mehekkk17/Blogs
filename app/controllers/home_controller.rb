# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    if params[:clear]
      session.delete(:posts_q)
      session.delete(:posts_sort)
      redirect_to root_path and return
    end

    session[:posts_q] = params[:q] if params.key?(:q)
    session[:posts_sort] = params[:sort] if params.key?(:sort)

    @search = (params[:q].presence || session[:posts_q]).to_s.strip
    sort = (params[:sort].presence || session[:posts_sort]).to_s
    @sort = sort.presence || "latest"
    order = @sort == "earliest" ? :asc : :desc

    @posts = Post
      .visible_for(current_user)
      .search_by_keyword(@search)
      .includes(:user)
      .order(created_at: order)
  end
end
