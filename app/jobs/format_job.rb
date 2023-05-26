# frozen_string_literal: true

class FormatJob < Gush::Job
  def perform
    photo_album = PhotoAlbum.find(params[:photo_album_id])
    Rails.logger.info "Starting FormatJob for photo_album #{photo_album.id}"

    convert_files(photo_album)
    photo_album.reload # Reload the object as we have updated the images
    create_vatiants(photo_album)
    photo_album.save!
  end

  def create_vatiants(photo_album)
    photo_album.images.each do |image|
      image.variant(resize_to_fit: [600, 600]).processed
    end
  end

  def convert_files(photo_album)
    images_to_delete = [] # Can I delete inline?
    photo_album.images.each do |image|
      next if image.blob.content_type == 'image/jpeg'

      Rails.logger.info "Converting #{image.blob.filename} to a JPEG"
      jpeg_blob = convert_to_jpg(image)
      images_to_delete << image
      photo_album.images.attach(jpeg_blob)
      photo_album.save!
    end

    images_to_delete.each(&:destroy!)

    photo_album.save!
  end

  def convert_to_jpg(image)
    image.blob.open do |tmpfile|
      jpg = ImageProcessing::Vips.source(tmpfile).convert!('jpg')
      filename = image.blob.filename
      jpeg_blob = ActiveStorage::Blob.create_and_upload!(
        io: jpg,
        filename: filename.to_s.gsub(filename.extension, 'jpg'),
        service_name: image.blob.service.name
      )
      jpeg_blob.save!
      jpeg_blob
    end
  end
end
