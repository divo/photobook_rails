class GelatoWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    Rails.logger.info("Gelato webhook received")
    payload = JSON.parse(request.body.read)

    if payload['object'] == 'orderStatus'
      update_order(payload)
    end

    return head :ok
  end

  private

  def update_order(payload)
    order = Order.find(payload['orderReferenceId'])
    Rails.logger.error "⚠️  Order #{order.id} not found" if order.nil?
    order.update_gelato_state(payload['fulfillmentStatus'])

    if payload['fulfillmentStatus'] == "shipped"
      item = payload['items'].first
      order.update(tracking_url: item['fulfillments'].first['trackingUrl'])
    end
  end
end
