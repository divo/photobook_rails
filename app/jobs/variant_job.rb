class VariantJob < Gush::Job
  def perform
    photo_album = PhotoAlbum.find(params[:photo_album_id])
    Rails.logger.info "Starting VariantJob for photo_album #{photo_album.id}"
    photo_album.images.each do |image|
      image.variant(resize_to_fit: [600, 600]).processed
    end
  end
end
