# frozen_string_literal: true

require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "get signup form" do
    get signup_path
    assert_response :success
    assert_select "form"
    assert_select "input[name=?]", "user[email]"
    assert_select "input[name=?]", "user[password]"
    assert_select "input[name=?]", "user[password_confirmation]"
  end

  test "signup form with valid data creates user and logs in" do
    get signup_path
    assert_difference "User.count", 1 do
      post users_path, params: {
        authenticity_token: authenticity_token_from_response,
        user: {
          email: "newuser@example.com",
          password: "secret6",
          password_confirmation: "secret6",
          name: "New User"
        }
      }
    end
    assert_redirected_to root_path
    assert_not_nil session[:user_id]
    assert_equal "newuser@example.com", User.find(session[:user_id]).email
    follow_redirect!
    assert_match /account created/i, flash[:notice].to_s
  end

  test "signup form with invalid email re-renders form" do
    get signup_path
    assert_no_difference "User.count" do
      post users_path, params: {
        authenticity_token: authenticity_token_from_response,
        user: {
          email: "",
          password: "secret6",
          password_confirmation: "secret6",
          name: "No Email"
        }
      }
    end
    assert_response :unprocessable_entity
    assert_select "form"
    assert_nil session[:user_id]
  end

  test "signup form with short password re-renders form" do
    get signup_path
    assert_no_difference "User.count" do
      post users_path, params: {
        authenticity_token: authenticity_token_from_response,
        user: {
          email: "short@example.com",
          password: "short",
          password_confirmation: "short",
          name: "Short"
        }
      }
    end
    assert_response :unprocessable_entity
    assert_select "form"
  end

  test "signup form with mismatched password confirmation re-renders form" do
    get signup_path
    assert_no_difference "User.count" do
      post users_path, params: {
        authenticity_token: authenticity_token_from_response,
        user: {
          email: "mismatch@example.com",
          password: "secret6",
          password_confirmation: "different",
          name: "Mismatch"
        }
      }
    end
    assert_response :unprocessable_entity
    assert_select "form"
  end

  test "signup form with duplicate email re-renders form" do
    get signup_path
    assert_no_difference "User.count" do
      post users_path, params: {
        authenticity_token: authenticity_token_from_response,
        user: {
          email: users(:one).email,
          password: "secret6",
          password_confirmation: "secret6",
          name: "Duplicate"
        }
      }
    end
    assert_response :unprocessable_entity
    assert_select "form"
  end
end
