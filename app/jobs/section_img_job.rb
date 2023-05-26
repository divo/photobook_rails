require 'down'

class SectionImgJob < Gush::Job
  def perform
    photo_album = PhotoAlbum.find(params[:photo_album_id])
    # Download section images and add them to the album in the correct positions

    return unless validate(photo_album)

    countries = photo_album.images.uniq { |image| image.blob.metadata['geocode']['country'] }
    # TODO: Break this out into it's own job
    # Use the GPS data from the first image in each country to get a map
    countries.each do |image|
      # Treat images without GPS data as if they are in the same "nil" country
      next if image.blob.metadata['geocode']['country'] == nil

      # Fetch each country image and store it
      lat, lon = image.blob.metadata.values_at('latitude', 'longitude')
      url = image_url(lat, lon)

      # TODO: Check response

      img_file = Down.download(url, extension: 'png')
      blob = ActiveStorage::Blob.create_and_upload!(
        io: File.open(img_file),
        filename: "#{image.blob.metadata['geocode']['country']}.png",
      )
      blob.metadata['geocode'] = { 'country' => image.blob.metadata['geocode']['country'] } # Copy over the country
      blob.metadata['section_page'] = true
      blob.save! # TODO: Handle adding more section than allowed max_image. Probably just stop the job here

      photo_album.images.attach(blob)
    end
  end

  def image_url(lat, lon, zoom = 7)
    "https://api.mapbox.com/styles/v1/divodivenson/clbfjkloe000k14qmi08wnngl/static/#{lon},#{lat},#{zoom},0/1280x1280@2x?access_token=#{Rails.application.credentials[:mapbox_key]}"
  end

  def validate(photo_album)
    no_geocode = photo_album.images.reject { |x| x.blob.metadata['geocode'] }
    no_geocode.each { |image| Rails.logger.error "#{self.class}: Geocode not found #{image.blob.metadata}" }
    if no_geocode.count == photo_album.images.count
      Rails.logger.error "#{self.class}: No geocode found for any images"
      return false
    end
    true
  end
end
