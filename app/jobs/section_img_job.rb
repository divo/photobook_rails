require 'down'

# Download section images and add them to the album in the correct positions
class SectionImgJob < Gush::Job
  def perform
    photo_album = PhotoAlbum.find(params[:photo_album_id])
    return unless validate(photo_album)

    countries = photo_album.geocodes
                           .select(&:present?)
                           .uniq { |geo| geo.to_h['country'] }

    # TODO: Break this out into it's own job
    # Use the GPS data from the first image in each country to get a map
    countries.each do |geocode|
      # Treat images without GPS data as if they are in the same "nil" country
      geo_h = geocode.to_h
      next if geo_h['country'].nil?

      url = image_url(geocode.lat, geocode.lng)

      # TODO: Check response

      img_file = Down.download(url, extension: 'png')
      blob = ActiveStorage::Blob.create_and_upload!(
        io: File.open(img_file),
        filename: "#{geo_h['country']}.png"
      )
      Geocode.new(photo_album: photo_album, active_storage_blob: geocode.active_storage_blob, geocode: geo_h.to_json, lat: geocode.lat, lng: geocode.lng).save!

      blob.metadata['section_page'] = true # I wonder is this failing to save too?
      blob.save! # TODO: Handle adding more section than allowed max_image. Probably just stop the job here

      photo_album.images.attach(blob)
    end
  end

  def image_url(lat, lon, zoom = 7)
    "https://api.mapbox.com/styles/v1/divodivenson/clbfjkloe000k14qmi08wnngl/static/#{lon},#{lat},#{zoom},0/1280x1280@2x?access_token=#{Rails.application.credentials[:mapbox_key]}"
  end

  def validate(photo_album)
    no_geocode = photo_album.geocodes.reject(&:present?)
    if no_geocode.count == photo_album.images.count
      Rails.logger.error "#{self.class}: No geocode found for any images"
      return false
    end
    true
  end
end
