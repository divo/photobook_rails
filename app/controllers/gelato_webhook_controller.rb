class GelatoWebhookController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    Rails.logger.info("Gelato webhook received")
    payload = request.body.read
    sig_header = request.env['GELATO_TOKEN']
    unless sig_header == Rails.application.credentials[:gelato_webhook_secret]
      Rails.logger.error "⚠️  Webhook signature verification failed"
      return head :bad_request
    end

    if payload['object'] == 'orderStatus'
      update_order(payload)
    end
  end

  private

  def update_order(payload)
    order = Order.find(payload['orderReferenceId'])
    order.update_gelato_status(payload['fulfillmentStatus'])

    if payload['fulfillmentStatus'] == "shipped"
      item = payload['items'].first
      order.tracking_url = item['fulfillments']['trackingUrl']
    end
  end
end
