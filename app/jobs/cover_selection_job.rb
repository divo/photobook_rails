# Selects a cover for a photo album
# Needs to be done in a job because the matadata needs to be processed
# first by exif.rb
class CoverSelectionJob < Gush::Job
  def perform
    photo_album = PhotoAlbum.find(params[:photo_album_id])
    select_cover(photo_album)
  end

  def select_cover(photo_album)
    image = photo_album.images.first { |i| self.valid_cover?({ 'width' => i.blob.metadata['width'], 'height' => i.blob.metadata['height'] }) } # Ugh
    if image
      image.blob.metadata['cover'] = true
      image.save
    end
  end
end
