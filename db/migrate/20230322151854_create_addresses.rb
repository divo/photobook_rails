class CreateAddresses < ActiveRecord::Migration[7.0]
  def change
    create_table :addresses, id: :uuid do |t|
      t.string :name
      t.string :line_1
      t.string :line_2
      t.string :state
      t.string :city
      t.string :post_code
      t.string :country
      t.string :email
      t.string :phone

      t.timestamps
    end
  end
end
