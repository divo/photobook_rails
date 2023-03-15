class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders, id: :uuid do |t|
      t.references :photo_album, null: false, foreign_key: true, type: :uuid
      t.references :order_estimate, null: false, foreign_key: true, type: :uuid
      t.integer :state, default: 0

      t.timestamps
    end
  end
end
