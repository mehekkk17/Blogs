# frozen_string_literal: true

require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @post = posts(:one)
    @user = users(:one)
    @other_user = users(:two)
  end

  # --- Show (no login required for public) ---
  test "show public post when not logged in" do
    get post_path(@post)
    assert_response :success
    assert_select "h1", @post.title
    assert_select ".post-show-body", @post.body
  end

  test "show public post when logged in" do
    log_in_as @user
    get post_path(@post)
    assert_response :success
    assert_select "h1", @post.title
  end

  test "show private post as owner" do
    log_in_as @user
    get post_path(posts(:private_post))
    assert_response :success
    assert_select "h1", posts(:private_post).title
  end

  test "show private post redirects when not owner and not logged in" do
    get post_path(posts(:private_post))
    assert_redirected_to root_path
    assert_match /not available/i, flash[:alert].to_s
  end

  test "show private post redirects when logged in as other user" do
    log_in_as @other_user
    get post_path(posts(:private_post))
    assert_redirected_to root_path
    assert_match /not available/i, flash[:alert].to_s
  end

  # --- New / Create form ---
  test "new post requires login" do
    get new_post_path
    assert_redirected_to login_path
    assert_match /sign in/i, flash[:alert].to_s
  end

  test "get new post form when logged in" do
    log_in_as @user
    get new_post_path
    assert_response :success
    assert_select "form[action=?]", posts_path
    assert_select "input[name=?]", "post[title]"
    assert_select "textarea[name=?]", "post[body]"
    assert_select "input[name=?]", "post[visibility]"
    assert_select "input[name=?]", "post[images][]"
  end

  def post_params_with_csrf(post_attrs)
    get new_post_path
    { authenticity_token: authenticity_token_from_response, post: post_attrs }
  end

  def edit_params_with_csrf(post_attrs)
    get edit_post_path(@post)
    { authenticity_token: authenticity_token_from_response, post: post_attrs }
  end

  test "create post form with valid params" do
    log_in_as @user
    assert_difference "Post.count", 1 do
      post posts_path, params: post_params_with_csrf(
        title: "New post title",
        body: "New post body.",
        visibility: "public"
      )
    end
    assert_redirected_to root_path
    assert_match /created/i, flash[:notice].to_s
    created = Post.last
    assert_equal "New post title", created.title
    assert_equal "New post body.", created.body
    assert_equal @user.id, created.user_id
    assert_equal "public", created.visibility
  end

  test "create post form with private visibility" do
    log_in_as @user
    post posts_path, params: post_params_with_csrf(
      title: "Private", body: "Private body.", visibility: "private"
    )
    assert_redirected_to root_path
    assert_equal "private", Post.last.visibility
  end

  test "create post form with blank title re-renders form" do
    log_in_as @user
    assert_no_difference "Post.count" do
      post posts_path, params: post_params_with_csrf(
        title: "", body: "Body here.", visibility: "public"
      )
    end
    assert_response :unprocessable_entity
    assert_select "form[action=?]", posts_path
  end

  test "create post form with blank body re-renders form" do
    log_in_as @user
    assert_no_difference "Post.count" do
      post posts_path, params: post_params_with_csrf(
        title: "Title", body: "", visibility: "public"
      )
    end
    assert_response :unprocessable_entity
    assert_select "form[action=?]", posts_path
  end

  # --- Edit / Update form ---
  test "edit post requires login" do
    get edit_post_path(@post)
    assert_redirected_to login_path
  end

  test "edit post requires owner" do
    log_in_as @other_user
    get edit_post_path(@post)
    assert_redirected_to root_path
    assert_match /only edit/i, flash[:alert].to_s
  end

  test "get edit post form as owner" do
    log_in_as @user
    get edit_post_path(@post)
    assert_response :success
    assert_select "form[action=?]", post_path(@post)
    assert_select "input[name=?]", "post[title]"
    assert_select "textarea[name=?]", "post[body]"
    assert_select "input[name=?]", "post[visibility]"
  end

  test "update post form with valid params" do
    log_in_as @user
    patch post_path(@post), params: edit_params_with_csrf(
      title: "Updated title", body: "Updated body.", visibility: "public"
    )
    assert_redirected_to root_path
    assert_match /updated/i, flash[:notice].to_s
    @post.reload
    assert_equal "Updated title", @post.title
    assert_equal "Updated body.", @post.body
  end

  test "update post form with invalid params re-renders edit" do
    log_in_as @user
    patch post_path(@post), params: edit_params_with_csrf(
      title: "", body: @post.body, visibility: "public"
    )
    assert_response :unprocessable_entity
    assert_select "form[action=?]", post_path(@post)
    @post.reload
    assert_equal "First post", @post.title
  end

  test "update post as other user redirects" do
    log_in_as @other_user
    get root_path
    patch post_path(@post), params: params_with_csrf.merge(
      post: { title: "Hacked", body: @post.body, visibility: "public" }
    )
    assert_redirected_to root_path
    assert_match /only edit/i, flash[:alert].to_s
    @post.reload
    assert_equal "First post", @post.title
  end

  # --- Destroy ---
  test "destroy post requires login" do
    get root_path
    assert_no_difference "Post.count" do
      delete post_path(@post), params: params_with_csrf
    end
    assert_redirected_to login_path
  end

  test "destroy post requires owner" do
    log_in_as @other_user
    get root_path
    assert_no_difference "Post.count" do
      delete post_path(@post), params: params_with_csrf
    end
    assert_redirected_to root_path
    assert_match /only edit/i, flash[:alert].to_s
  end

  test "destroy post as owner" do
    log_in_as @user
    get root_path
    assert_difference "Post.count", -1 do
      delete post_path(@post), params: params_with_csrf
    end
    assert_redirected_to root_path
    assert_match /deleted/i, flash[:notice].to_s
  end
end
