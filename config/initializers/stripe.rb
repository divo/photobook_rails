if ENV['RAILS_ENV'] # Workaround for creds not available in asset precompile
  Stripe.api_key = Rails.application.credentials[:stripe][:api_key]
end
