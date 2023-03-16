class OrderEstimate < ApplicationRecord
  belongs_to :photo_album
  validates :gelato_price, numericality: { greater_than: 0 } # TODO: Enable and handle this

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
      price: calculate_price(quote['products'].first['price']),
      gelato_price: quote['products'].first['price'],
      shipping_price: quote['shipmentMethods'].first['price'],
      min_delivery_days: quote['shipmentMethods'].first['minDeliveryDays'],
      max_delivery_days: quote['shipmentMethods'].first['maxDeliveryDays'],
      currency: quote['products'].first['currency'],
      shipping_name: quote['shipmentMethods'].first['name']
    )
  end

  private

  def self.calculate_price(gelato_price)
    (gelato_price + 5).ceil
  end
end
