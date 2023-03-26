module Prices
  def self.margin
    5.0 + Prices.vat(5.0)
  end

  def self.vat(cost)
    cost * 0.23
  end
end