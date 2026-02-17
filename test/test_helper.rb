# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    fixtures :all

    # Log in by loading the login form (for CSRF token) then posting credentials.
    def log_in_as(user, password: "password")
      get login_path
      token = authenticity_token_from_response
      post login_path, params: { authenticity_token: token, email: user.email, password: password }
    end

    # Extract CSRF token from the last response body (form or meta tag).
    def authenticity_token_from_response
      body = response.body
      m = body.match(/name="authenticity_token"\s+value="([^"]+)"/) ||
          body.match(/name="csrf-token"\s+content="([^"]+)"/) ||
          body.match(/content="([^"]+)"\s+name="csrf-token"/)
      m ? m[1] : nil
    end

    # Include authenticity token in params for a request (e.g. delete).
    def params_with_csrf(params = {})
      get root_path unless response.body.present?
      token = authenticity_token_from_response
      params.merge(authenticity_token: token)
    end
  end
end
