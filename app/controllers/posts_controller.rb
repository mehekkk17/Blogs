# frozen_string_literal: true

class PostsController < ApplicationController
  before_action :require_login, only: %i[ new create edit update destroy ]
  before_action :set_post, only: %i[ show edit update destroy ]
  before_action :authorize_post_owner, only: %i[ edit update destroy ]
  before_action :authorize_post_visible, only: %i[ show ]

  def show
  end

  def new
    @post = current_user.posts.build(visibility: "public")
  end

  def create
    @post = current_user.posts.build(post_params)
    if @post.save
      redirect_to root_path, notice: "Post created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    attrs = post_params.to_h
    new_images = attrs.delete("images")  # don't pass to update so existing images aren't replaced
    if @post.update(attrs)
      purge_removed_images  # only purge after successful update
      @post.images.attach(new_images) if new_images.present?
      redirect_to root_path, notice: "Post updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_to root_path, notice: "Post deleted."
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def authorize_post_owner
    return if @post.user_id == current_user.id
    redirect_to root_path, alert: "You can only edit or delete your own posts."
  end

  def authorize_post_visible
    return if @post.public?
    return if current_user && @post.user_id == current_user.id
    redirect_to root_path, alert: "That post is not available."
  end

  def purge_removed_images
    ids = Array(params.dig(:post, :remove_image_ids)).reject(&:blank?).map(&:to_s)
    return if ids.empty?
    # Legacy single image
    if @post.image.attached? && ids.include?(@post.image.blob.id.to_i)
      @post.image.purge
    end
    # Multiple images: purge by blob id (ids are blob ids from the form)
    @post.images.attachments.where(id: ids).map(&:purge)
  end

  def post_params
    params.require(:post).permit(:title, :body, :visibility, :image, images: [])
  end
end
