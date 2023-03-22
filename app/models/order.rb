class Order < ApplicationRecord
  include AASM

  belongs_to :photo_album
  belongs_to :order_estimate # This should be a clone of the PhotoAlbum's OrderEstimate, as to lock it in time
  has_one :address, dependent: :destroy

  has_one_attached :rendered_album, service: :orders_bucket

  enum state: {
    draft: 0,
    paid: 1,
    payment_failed: 2,
  }

  aasm column: :state, enum: true do
    state :draft, initial: true
    state :paid
    state :payment_failed

    event :pay do
      transitions from: :draft, to: :paid
      after do
        RenderAlbumJob.perform_later(photo_album.present { |image| image.url }, self)
      end
    end

    event :payment_failed do
      transitions from: :draft, to: :payment_failed
      after do
        # TODO: Send email to me and probably the user
        Rails.logger.error "Payment failed for order #{id}"
      end
    end
  end
end

