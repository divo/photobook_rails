class AddAddressToOrder < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :address_id, :uuid
  end
end
