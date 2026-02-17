# frozen_string_literal: true

require_relative "boot"

require "rails"
require "active_model/railtie"
require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
require "action_dispatch/railtie"
require "action_mailer/railtie"
require "active_job/railtie"
require "active_storage/engine"

Bundler.require(*Rails.groups)

module NcgBlog
  class Application < Rails::Application
    config.load_defaults 7.2
    config.generators.system_tests = nil
  end
end
