class BuildCompleteJob < Gush::Job
  def perform
    photo_album = PhotoAlbum.find(params[:photo_album_id])
    photo_album.build_status = "build_complete"
    photo_album.save!
  end
end
