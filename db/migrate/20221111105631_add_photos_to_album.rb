class AddPhotosToAlbum < ActiveRecord::Migration[7.0]
  def self.up
    add_column :photos, :photo_album_id, :integer
    add_index 'photos', ['photo_album_id'], :name => 'index_photo_album_id'
  end

  def self.down
    remove_column :photos, :photo_album_id
  end
end
