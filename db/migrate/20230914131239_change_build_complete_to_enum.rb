class ChangeBuildCompleteToEnum < ActiveRecord::Migration[7.0]
  def up
    add_column :photo_albums, :build_status, :integer, default: 0
    PhotoAlbum.reset_column_information
    PhotoAlbum.update_all(build_status: 0)
    PhotoAlbum.all.each do |album|
      album.update(build_status: 2) if album.build_complete
    end
    remove_column :photo_albums, :build_complete
  end

  def down
    add_column :photo_albums, :build_complete, :boolean, default: false
    PhotoAlbum.reset_column_information
    PhotoAlbum.update_all(build_complete_boolean: false)
    PhotoAlbum.all.each do |album|
      album.update(build_complete: true) if album.build_status == 2
    end
    remove_column :photo_albums, :build_status
  end
end
