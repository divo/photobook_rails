class CreateGeocodes < ActiveRecord::Migration[7.0]
  def change
    create_table :geocodes, id: :uuid do |t|
      t.references :photo_album, null: false, foreign_key: true, type: :uuid
      t.references :active_storage_blob, null: false, foreign_key: true, type: :uuid
      t.string :geocode
      t.string :lat
      t.string :lng

      t.timestamps
    end
  end
end
