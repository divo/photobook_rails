class OrderEstimate < ApplicationRecord
  belongs_to :photo_album

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
