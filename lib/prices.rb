module Prices
  def self.margin
    5.0
  end

  def self.margin_incl_vat
    Prices.vat(Prices.margin) + Prices.margin
  end

  def self.vat(cost)
    cost * 0.23
  end
end