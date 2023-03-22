class WebhooksController < ApplicationController
  include ActiveStorage::SetCurrent
  skip_before_action :verify_authenticity_token

  def create
    Rails.logger.info("Webhook received")
    payload = request.body.read
    sig_header = request.env['HTTP_STRIPE_SIGNATURE']
    event = nil

    # TODO: Change the prod secret to live secret before going live
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
      return head :bad_request
    rescue Stripe::SignatureVerificationError => e
      Rails.logger.error "⚠️  Webhook signature verification failed: #{e.message}"
      return head :bad_request
    end

    case event.type
    when 'checkout.session.completed'
      session = event.data.object
      # TODO: Kickoff render job, send the result to Gelato
      # a notification to the user and a notification to me
      # #<Stripe::Checkout::Session:0xffb4 id=cs_test_a1pP54PsvNqhBRBX2yCOv5lKCmrTMbT2cTQSB63h086gfsMXVTKKivKI1M> JSON: {
      #   "id": "cs_test_a1pP54PsvNqhBRBX2yCOv5lKCmrTMbT2cTQSB63h086gfsMXVTKKivKI1M",
      #   "object": "checkout.session",
      #   "after_expiration": null,
      #   "allow_promotion_codes": null,
      #   "amount_subtotal": 1800,
      #   "amount_total": 2221,
      #   "automatic_tax": {"enabled":false,"status":null},
      #   "billing_address_collection": null,
      #   "cancel_url": "http://localhost:3000/checkout/cancel.html",
      #   "client_reference_id": null,
      #   "consent": null,
      #   "consent_collection": null,
      #   "created": 1678813513,
      #   "currency": "eur",
      #   "custom_fields": [
      #
      #   ],
      #   "custom_text": {"shipping_address":null,"submit":null},
      #   "customer": null,
      #   "customer_creation": "if_required",
      #    # TODO: I'll need to store the customer details for the order
      #   "customer_details": {"address":{"city":"Dublin","country":"IE","line1":"8 Caledon Court","line2":"East Wall","postal_code":"D03 DC60","state":"County Dublin"},"email":"divodivenson@gmail.com","name":"Steven Diviney","phone":null,"tax_exempt":"none","tax_ids":[]},
      #    # TODO: If this is something they can change I'll need to store it
      #   "customer_email": "divodivenson@gmail.com",
      #   "expires_at": 1678899913,
      #   # TODO: Do I need an invoice?
      #   "invoice": null,
      #   "invoice_creation": {"enabled":false,"invoice_data":{"account_tax_ids":null,"custom_fields":null,"description":null,"footer":null,"metadata":{},"rendering_options":null}},
      #   "livemode": false,
      #   "locale": null,
      #   "metadata": {"photo_album_id":"2b50b4b8-ea35-4b94-80c3-3781ed891631"},
      #   "mode": "payment",
      #   "payment_intent": "pi_3MlbIWH6pkkcX6Rl0dBNGCdn",
      #   "payment_link": null,
      #   "payment_method_collection": "always",
      #   "payment_method_options": {},
      #   "payment_method_types": [
      #     "card"
      #   ],
      #   "payment_status": "paid",
      #   "phone_number_collection": {"enabled":false},
      #   "recovered_from": null,
      #   "setup_intent": null,
      #   "shipping_address_collection": {"allowed_countries":["IE"]},
      #   "shipping_cost": {"amount_subtotal":421,"amount_tax":0,"amount_total":421,"shipping_rate":"shr_1MlbHhH6pkkcX6RlMdMaoysI"},
      #   "shipping_details": {"address":{"city":"Dublin","country":"IE","line1":"8 Caledon Court","line2":"East Wall","postal_code":"D03 DC60","state":"County Dublin"},"name":"Steven Diviney"},
      #   "shipping_options": [
      #     {"shipping_amount":421,"shipping_rate":"shr_1MlbHhH6pkkcX6RlMdMaoysI"}
      #   ],
      #   "status": "complete",
      #   "submit_type": null,
      #   "subscription": null,
      #   "success_url": "http://localhost:3000/checkout/success.html",
      #   "total_details": {"amount_discount":0,"amount_shipping":421,"amount_tax":0},
      #   "url": null
      # }
      Rails.logger.info("Webhook #{session.id} metadata: #{session.metadata}")
      order = Order.find(session.metadata.order_id)

      Rails.logger.error("Order not found! #{session}") unless order

      if session.payment_status == 'paid'
        Rails.logger.info("Webhook #{session.id} Order paid!")
        address = Address.build_from_stripe(session, order)
        address.save!
        order.pay!
      else
        Rails.logger.warn("Webhook #{session.id} Order payment failed")
        order.payment_failed!
      end
    end

    render json: { status: 'success' }
  end
end
