class CreatePhotoAlbums < ActiveRecord::Migration[7.0]
  def change
    create_table :photo_albums, id: :uuid do |t|
      t.string :name

      t.timestamps
    end
  end
end
