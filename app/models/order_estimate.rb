class OrderEstimate < ApplicationRecord
  belongs_to :photo_album

  after_commit -> { broadcast_replace_to photo_album, partial: "order_estimates/order_estimate", locals: { order_estimate: self }, target: "estimate" }

  def total_price
    "#{price + shipping_price}"
  end

  def currency_symbol
    Money.new(0, currency).symbol
  end

  def self.build_estimate(photo_album, quotes)
    quote = quotes['quotes'].first
    OrderEstimate.new(
      photo_album: photo_album,
      price: quote['products'].first['price'],
      shipping_price: quote['shipmentMethods'].first['price'],
      min_delivery_days: quote['shipmentMethods'].first['minDeliveryDays'],
      max_delivery_days: quote['shipmentMethods'].first['maxDeliveryDays'],
      currency: quote['products'].first['currency']
    )
  end
end
