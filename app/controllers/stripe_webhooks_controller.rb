class StripeWebhooksController < ApplicationController
  include ActiveStorage::SetCurrent
  skip_before_action :verify_authenticity_token

  def create
    Rails.logger.info("✅ Stripe webhook received")
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    event = nil

    secret =
      if Rails.env.development?
        Rails.application.credentials[:stripe][:webhook_secret_dev]
      else
        Rails.application.credentials[:stripe][:webhook_secret_prod]
      end

    begin
      event = Stripe::Webhook.construct_event(
        payload, sig_header, secret
      )
    rescue JSON::ParserError => e
      Rails.logger.error "⚠️  Webhook failed, bad message: #{e.message}"
      return head :bad_request
    rescue Stripe::SignatureVerificationError => e
      Rails.logger.error "⚠️  Webhook signature verification failed: #{e.message}"
      return head :bad_request
    end

    case event.type
    when 'checkout.session.completed'
      session = event.data.object
      # TODO: Store the amount the pay me!
      Rails.logger.info("Webhook #{session.id} metadata: #{session.metadata}")
      order = Order.find(session.metadata.order_id)

      Rails.logger.error("⚠️  Order not found! #{session}") unless order

      if session.payment_status == 'paid'
        Rails.logger.info("✅ Webhook #{session.id} Order paid!")
        address = Address.build_from_stripe(session.shipping_details, session.customer_email, order)
        address.save!
        order.pay!
      else
        Rails.logger.warn("⚠️  Webhook session: #{session.id} Order: #{order.id} payment failed")
        order.payment_failed!
      end
    end

    render json: { status: 'success' }
  end
end
