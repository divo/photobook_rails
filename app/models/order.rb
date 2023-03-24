class Order < ApplicationRecord
  include AASM

  belongs_to :photo_album
  has_one :order_estimate, as: :estimateable
  has_one :address, dependent: :destroy

  has_one_attached :rendered_album, service: :orders_bucket

  enum state: {
    draft: 0,
    paid: 1,
    payment_failed: 2,
    rendered: 3,
    render_failed: 4,
    order_created: 5,
    order_creation_failed: 6
  }

  aasm column: :state, enum: true do
    state :draft, initial: true
    state :paid
    state :payment_failed
    state :rendered
    state :render_failed
    state :order_created
    state :order_creation_failed

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
  end
end

