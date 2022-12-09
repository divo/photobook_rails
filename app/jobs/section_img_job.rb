require 'down'

class SectionImgJob < ApplicationJob
  queue_as :default

  def perform(photo_album)
    # Download section images and add them to the album in the correct positions
    countries = photo_album.images.uniq { |image| image.blob.metadata['geocode']['address']['country'] }
    countries.each do |image|
      # Fetch each country image and store it
      lat, lon = image.blob.metadata['geocode'].values_at('lat', 'lon')
      url = image_url(lat, lon)

      # TODO: Check response

      img_file = Down.download(url, extension: 'png')
      blob = ActiveStorage::Blob.create_and_upload!(
        io: File.open(img_file),
        filename: "#{image.blob.metadata['geocode']['address']['country']}.png",
      )
      blob.metadata['geocode'] = { 'address' => { 'country' => image.blob.metadata['geocode']['address']['country'] } } # Copy over the country
      blob.metadata['section_page'] = true
      blob.save!

      photo_album.images.attach(blob)
    end
  end

  def image_url(lat, lon, zoom = 7)
    "https://api.mapbox.com/styles/v1/divodivenson/clbfjkloe000k14qmi08wnngl/static/#{lon},#{lat},#{zoom},0/1280x1280@2x?access_token=pk.eyJ1IjoiZGl2b2RpdmVuc29uIiwiYSI6ImNqcGwzdnN0NDA5aDg0MnBrNGhvanR5MTkifQ.k4YAweTizPCJRbJiZ-7c8g"
  end
end
