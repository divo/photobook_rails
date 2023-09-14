# frozen_string_literal: true
class FormatCompleteJob < Gush::Job
  def perform
    photo_album = PhotoAlbum.find(params[:photo_album_id])
    photo_album.build_status = 'images_converted'
    photo_album.save!
  end
end
