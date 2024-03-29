# frozen_string_literal: true

class FormatJob < Gush::Job
  def perform
    photo_album = PhotoAlbum.find(params[:photo_album_id])
    image = photo_album.images.find(params[:image_id])
    Rails.logger.info "Starting FormatJob for photo_album #{photo_album.id} and image #{image.id}}"

    return unless needs_conversion?(image)

    new_image = convert_file(photo_album, image)
    # Create the vairants ahread of time to improve on page experience
    # it takes far to long to create them when the page is loaded, looks very poor.
    create_vatiant(new_image)
    photo_album.save!
  end

  # Need to convert files that 1) Have rotation applied in exif data as node-canvas
  # doesn't apply it 2) None jpegs, look at exif and file extension as the latter can confuse browers
  def needs_conversion?(image)
    result = image.blob.metadata[:orientation] != 1 ||
             image.blob.content_type != 'image/jpeg' ||
             image.blob.filename.extension != 'jpeg' ||
             image.blob.filename.extension != 'jpg'

    Rails.logger.info "Image #{image.blob.filename} needs conversion: #{result}" if result
    result
  end

  def create_vatiant(image)
    image.variant(resize_to_fit: [600, 600]).processed
  end

  def convert_file(photo_album, image)
    # Always convert, the file extention can confuse some browsers if incorrect
    # and node-canvas doesn't respect orientation metadata
    Rails.logger.info "Converting #{image.blob.filename} to a JPEG"
    jpeg_blob = convert_to_jpg(image)
    photo_album.images.attach(jpeg_blob)
    photo_album.save!

    image.destroy!
    photo_album.save! # Is this needed?

    jpeg_blob
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
