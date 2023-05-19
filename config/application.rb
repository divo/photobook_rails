require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# TODO: move to env
DEFAULT_HOST = "https://mementos.ink"

module PhotobookRails
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.autoload_paths += paths["lib"].to_a

    config.active_storage.variant_processor = :vips

    config.active_job.queue_adapter = :sidekiq

    ISO3166.configuration.enable_currency_extension!

    config.action_mailer.asset_host = DEFAULT_HOST
  end
end
