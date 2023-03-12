class CreateOrderEstimates < ActiveRecord::Migration[7.0]
  def change
    create_table :order_estimates, id: :uuid do |t|
      t.decimal :price
      t.decimal :shipping_price
      t.integer :min_delivery_days
      t.integer :max_delivery_days
      t.string :currency
      t.references :photo_album, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
