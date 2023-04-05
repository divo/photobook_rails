class OrderEstimate < ApplicationRecord
  belongs_to :estimateable, polymorphic: true
  validates :gelato_price, numericality: { greater_than: 0 }

  # Broadcast to the photo_album channel. There is no order channel
  after_commit -> { broadcast_replace_to estimateable, partial: "order_estimates/order_estimate", locals: { order_estimate: self }, target: "estimate" }

  def total
    "#{price_incl_vat.round(2)}"
  end

  def total_vat
    Prices.vat(price).round(2)
  end

  def unit_price
    gelato_price + Prices.margin
  end

  def price_incl_vat
    price + Prices.vat(price)
  end

  def currency_symbol
    Money.new(0, currency).symbol
  end

  def self.build_estimate(photo_album, quotes)
    # TODO: Wire in other shipping methods, they only seem to offer one in Ireland
    quote = quotes['quotes'].first
    OrderEstimate.new(
      estimateable: photo_album,
      price: calculate_price(quote['products'].first['price'], quote['shipmentMethods'].first['price']),
      gelato_price: quote['products'].first['price'],
      shipping_price: quote['shipmentMethods'].first['price'],
      min_delivery_days: quote['shipmentMethods'].first['minDeliveryDays'],
      max_delivery_days: quote['shipmentMethods'].first['maxDeliveryDays'],
      currency: quote['products'].first['currency'],
      shipping_name: quote['shipmentMethods'].first['name'],
      shipping_method_uuid: quote['shipmentMethods'].first['shipmentMethodUid'],
    )
  end

  private

  def self.calculate_price(gelato_price, shipping_price)
    gelato_price + shipping_price + Prices.margin
  end
end
