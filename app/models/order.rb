class Order < ApplicationRecord
  include AASM

  belongs_to :photo_album
  has_one :order_estimate, as: :estimateable, dependent: :destroy
  has_one :address, dependent: :destroy

  has_one_attached :rendered_album, service: :orders_bucket

  enum state: {
    draft: 0,
    checkout_success: 13,
    paid: 1,
    payment_failed: 2,
    rendered: 3,
    render_failed: 4,
    order_created: 5,
    order_creation_failed: 6,
    draft_canceled: 7,
    printing: 8,
    printing_failed: 9,
    printing_cancelled: 10,
    printed: 11,
    shipped: 12
  }

  aasm column: :state, enum: true do
    state :draft, initial: true
    state :checkout_success
    state :draft_canceled
    state :paid
    state :payment_failed
    state :rendered
    state :render_failed
    state :order_created
    state :order_creation_failed
    state :draft_canceled
    state :printing
    state :printing_failed
    state :printing_cancelled
    state :printed
    state :shipped

    event :cancel_draft do
      transitions from: :draft, to: :draft_canceled
      after do
        Rails.logger.info "✅ Order #{id} canceled"
      end
    end

    # PhotoAlbumsController will not attempt to checkout an order that is already paid
    # Sad that logic is in the controller
    event :checkout do
      transitions from: :draft, to: :checkout_success
      after do
        Rails.logger.info "✅ Order #{id} checkout success"
      end
    end

    event :pay do
      transitions from: :draft, to: :paid
      transitions from: :checkout_success, to: :paid
      after do
        Rails.logger.info "✅ Order #{id} paid"
        order_client = OrderClient.new(self.id, self.photo_album.user, self.photo_album.id)
        res = order_client.cover_dimensions(self.photo_album.final_page_count)

        OrderMailer.order_confirmation(self).deliver_later
        AdminMailer.order_placed(self).deliver_later

        if res.success? && res['spineSize']
          RenderAlbumJob.perform_later(photo_album.present { |image| image.url }, self, res['spineSize']['width'])
        else
          Rails.logger.error "⚠️  Order #{id} render failed, unable to get spine size."
          AdminMailer.order_failed(self).deliver_later
          self.render_failed!
        end
      end
    end

    event :render do
      transitions from: :paid, to: :rendered
      after do
        # Create the order with gelato
        order_client = OrderClient.new(self.id, self.photo_album.user, self.photo_album.id)
        res = order_client.place_order(self, self.photo_album.content_page_count, self.order_estimate.currency)
        if res.success?
          save_order_details(res)
          self.order_created!
          Rails.logger.info "✅ Order #{id} created"
        else
          Rails.logger.error "⚠️  Order #{id} creation failed"
          AdminMailer.order_failed(self).deliver_later
          self.order_creation_failed!
        end
      end
    end

    event :payment_failed do
      transitions to: :payment_failed
      after do
        Rails.logger.error "⚠️  Payment failed for order #{id}"
        AdminMailer.order_failed(self).deliver_later
      end
    end

    event :render_failed do
      transitions to: :render_failed
      after do
        Rails.logger.error "⚠️  Render failed for order #{id}"
        AdminMailer.order_failed(self).deliver_later
      end
    end

    event :awaiting_print do
      transitions from: :order_created, to: :printing
      after do
        Rails.logger.info "✅ Order #{id} is awaiting print"
      end
    end

    event :fail_printing do
      transitions to: :printing_failed
      after do
        Rails.logger.error "⚠️  Printing failed for order #{id}"
        AdminMailer.order_failed(self).deliver_later
      end
    end

    event :cancel_printing do
      transitions from: :printing, to: :printing_cancelled
      transitions from: :order_created, to: :printing_cancelled
      after do
        Rails.logger.error "⚠️  Printing cancelled for order #{id}"
        AdminMailer.order_failed(self).deliver_later
      end
    end

    event :print do
      transitions from: :printing, to: :printed
      after do
        Rails.logger.info "✅ Order #{id} has been printed"
      end
    end

    event :ship do
      transitions from: :printed, to: :shipped
      after do
        OrderMailer.order_shipped(self).deliver_later
        Rails.logger.info "✅✅ Order #{id} has been shipped"
      end
    end
  end

  def update_gelato_state(status)
    case status
    when 'passed'
      self.awaiting_print!
    when 'failed'
      self.fail_printing!
    when 'canceled'
      self.cancel_printing!
    when 'printed'
      self.print!
    when 'shipped'
      self.ship!
    end
  end

  # Need a little bit of logic to determine if the final price differes from the estimated price, due to order lifecycle
  def amount_paid
    unless total_price_incl_vat == order_estimate.price_incl_vat
      Rails.logger.warn "Order #{id} has a different price than the estimate"
    end
    order_estimate.total
  end

  def currency_symbol
    Money.new(0, currency).symbol
  end

  private

  def save_order_details(res)
    self.update(
      fulfillment_status: res['fulfillmentStatus'],
      financial_status: res['financialStatus'],
      gelato_id: res['id'],
      gelato_price: res['receipts'].first['productsPrice'], # Prices for item (no shipping)
      gelato_price_incl_vat: res['receipts'].first['productsPriceInclVat'], # Price for item incl vat (no shipping)
      total_gelato_price_incl_vat: res['receipts'].first['totalInclVat'], # Price + vat + shipping + shipping_vat
      shipping_method_uid: res['shipment']['shippingMethodUid'],
      shipping_price: res['receipts'].first['shippingPrice'],
      shipping_price_incl_vat: res['receipts'].first['shippingPriceInclVat'],
      margin: Prices.margin,
      total_price: Prices.margin + res['receipts'].first['total'], # Margin + Gelato price + shipping (no vat on any)
      total_price_incl_vat: Prices.margin_incl_vat + res['receipts'].first['totalInclVat'],
      currency: res['currency']
    )
  end
end

