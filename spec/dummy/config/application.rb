require_relative 'boot'

require 'action_controller/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
require 'view_component/fragment_caching'

module Dummy
  class Application < Rails::Application
    config.load_defaults Float(Rails::VERSION::STRING.split('.').first(2).join('.'))

    # For compatibility with applications that use this config
    config.action_controller.include_all_helpers = false

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
