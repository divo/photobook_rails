class Address < ApplicationRecord
  belongs_to :order

  def self.build_from_stripe(details, email, order)
    address = details.address
    Address.new(
      order: order,
      name: details.name,
      line_1: address.line1,
      line_2: address.line2,
      city: address.city,
      state: address.state,
      post_code: address.postal_code,
      country: address.country,
      email: email
    )
  end

  def to_gelato
    {
      firstName: name,
      addressLine1: line_1,
      addressLine2: line_2,
      city: city,
      state: state,
      postCode: post_code,
      country: country,
      email: email
    }
  end
end
