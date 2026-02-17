# frozen_string_literal: true

require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "get login when not logged in" do
    get login_path
    assert_response :success
    assert_select "form[action=?]", login_path
    assert_select "input[name=?]", "email"
    assert_select "input[name=?]", "password"
  end

  test "get login redirects to root when logged in" do
    log_in_as users(:one)
    get login_path
    assert_redirected_to root_path
  end

  test "login form with valid credentials" do
    get login_path
    post login_path, params: {
      authenticity_token: authenticity_token_from_response,
      email: users(:one).email,
      password: "password"
    }
    assert_redirected_to root_path
    assert_equal users(:one).id, session[:user_id]
    follow_redirect!
    assert_match /signed in/i, flash[:notice].to_s
  end

  test "login form with invalid password" do
    get login_path
    post login_path, params: {
      authenticity_token: authenticity_token_from_response,
      email: users(:one).email,
      password: "wrong"
    }
    assert_response :unprocessable_entity
    assert_nil session[:user_id]
    assert_select ".auth-alert", /invalid/i
  end

  test "login form with unknown email" do
    get login_path
    post login_path, params: {
      authenticity_token: authenticity_token_from_response,
      email: "nobody@example.com",
      password: "password"
    }
    assert_response :unprocessable_entity
    assert_nil session[:user_id]
  end

  test "logout" do
    log_in_as users(:one)
    get root_path
    delete logout_path, params: params_with_csrf
    assert_redirected_to login_path
    assert_nil session[:user_id]
    follow_redirect!
    assert_match /signed out/i, flash[:notice].to_s
  end
end
