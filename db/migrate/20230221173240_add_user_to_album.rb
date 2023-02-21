class AddUserToAlbum < ActiveRecord::Migration[7.0]
  def change
    add_column :photo_albums, :user_id, :integer
    add_index :photo_albums, :user_id
  end
end
