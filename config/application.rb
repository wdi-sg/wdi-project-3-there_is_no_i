require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module WdiProject3ThereIsNoI
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    config.time_zone = 'Singapore'
    config.active_record.default_timezone = :local
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Route exceptions to the application router vs. default
    config.exceptions_app = self.routes

    config.autoload_paths += %W(#{config.root}/lib)
  end
end
