class Address < ApplicationRecord
  belongs_to :order

  def self.build_from_stripe(session, order)
    details = session.shipping_details.address
    Address.new(
      order: order,
      name: details.name,
      line1: details.line1,
      line2: details.line2,
      city: details.city,
      state: details.state,
      postal_code: details.postal_code,
      country: details.country
    )
  end
end
