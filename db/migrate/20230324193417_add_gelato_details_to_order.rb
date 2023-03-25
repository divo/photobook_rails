class AddGelatoDetailsToOrder < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :fulfillment_status, :string
    add_column :orders, :financial_status, :string
    add_column :orders, :gelato_id, :string
    add_column :orders, :gelato_price, :decimal
    add_column :orders, :gelato_price_incl_vat, :decimal
    add_column :orders, :total_gelato_price_incl_vat, :decimal
    add_column :orders, :shipping_method_uid, :string
    add_column :orders, :shipping_price, :decimal
    add_column :orders, :shipping_price_incl_vat, :decimal
  end
end
