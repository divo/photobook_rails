class AddBuildCompleteToPhotoAlbum < ActiveRecord::Migration[7.0]
  def change
    add_column :photo_albums, :build_complete, :boolean, default: false
  end
end
