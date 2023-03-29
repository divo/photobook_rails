class Order < ApplicationRecord
  include AASM

  belongs_to :photo_album
  has_one :order_estimate, as: :estimateable, dependent: :destroy
  has_one :address, dependent: :destroy

  has_one_attached :rendered_album, service: :orders_bucket

  enum state: {
    draft: 0,
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
    end

    event :pay do
      transitions from: :draft, to: :paid
      after do
        order_client = OrderClient.new(self.id, self.photo_album.user, self.photo_album.id)
        res = order_client.cover_dimensions(self.photo_album.final_page_count)

        if res.success? && res['spineSize']
          RenderAlbumJob.perform_later(photo_album.present { |image| image.url }, self, res['spineSize']['width'])
        else
          self.render_failed!
        end
      end
    end

    event :render do
      transitions from: :paid, to: :rendered
      after do
        # Create the order with gelato
        order_client = OrderClient.new(self.id, self.photo_album.user, self.photo_album.id)
        res = order_client.place_order(self, self.photo_album.content_page_count)
        if res.success?
          save_order_details(res)
          self.order_created!
        else
          self.order_creation_failed!
        end
      end
    end

    event :payment_failed do
      transitions from: :draft, to: :payment_failed
      after do
        # TODO: Send email to me and probably the user
        Rails.logger.error "Payment failed for order #{id}"
      end
    end

    event :render_failed do
      transitions from: :paid, to: :render_failed
      after do
        Rails.logger.error "Render failed for order #{id}"
      end
    end

    event :awaiting_print do
      transitions from: :order_created, to: :printing
      after do
        Rails.logger.info "Order #{id} is awaiting print"
      end
    end

    event :printing_failed do
      transitions from: :printing, to: :printing_failed
      transitions from: :order_created, to: :printing_failed
      after do
        Rails.logger.error "Printing failed for order #{id}"
      end
    end

    event :printing_cancelled do
      transitions from: :printing, to: :printing_cancelled
      transitions from: :order_created, to: :printing_cancelled
      after do
        Rails.logger.error "Printing cancelled for order #{id}"
      end
    end

    event :printed do
      transitions from: :printing, to: :printed
      after do
        Rails.logger.info "Order #{id} has been printed"
      end
    end

    event :shipped do
      transitions from: :printed, to: :shipped
      after do
        Rails.logger.info "Order #{id} has been shipped"
      end
    end
  end

  def update_gelato_state(status)
    case status
    when 'passed'
      self.awaiting_print!
    when 'failed'
      self.printing_failed!
    when 'canceled'
      self.printing_cancelled!
    when 'printed'
      self.printed!
    when 'shipped'
      self.shipped!
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

