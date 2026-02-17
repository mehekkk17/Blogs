# frozen_string_literal: true

Rails.application.configure do
  config.active_storage.service = :test
  config.action_controller.allow_forgery_protection = false
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = true
end
