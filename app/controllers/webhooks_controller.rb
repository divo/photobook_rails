class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    byebug
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    event = nil

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, Rails.application.credentials[:stripe][:webhook_secret]
      )
    rescue JSON::ParserError => e
      render :nothing, status: :bad_request
    rescue Stripe::SignatureVerificationError => e
      Rails.logger.error "⚠️  Webhook signature verification failed: #{e.message}"
      render :nothing, status: :bad_request
    end

    case event.type
    when 'checkout.session.completed'
      session = event.data.object
      # TODO: Kickoff render job, send the result to Gelato
      # a notification to the user and a notification to me
    end

    render json: { status: 'success' }
  end
end
