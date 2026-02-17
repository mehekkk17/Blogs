# frozen_string_literal: true

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.public_file_server.enabled = true
  config.log_level = :info
  # Active Storage: use local disk (on Render this is ephemeral; files are lost on redeploy unless you use S3 etc.)
  config.active_storage.service = :local
  # Log to stdout so Render (and similar hosts) show errors in the dashboard
  if ENV["RAILS_LOG_TO_STDOUT"].present?
    config.logger = ActiveSupport::Logger.new($stdout)
    config.logger.formatter = config.log_formatter
  end
end
