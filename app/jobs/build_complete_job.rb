class BuildCompleteJob < Gush::Job
  def perform
    photo_album = PhotoAlbum.find(params[:photo_album_id])
    photo_album.build_complete = true
    photo_album.save!
  end
end
