class AddCountryToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :country_code, :string
  end
end
