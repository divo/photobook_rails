class GeocoderJob < ApplicationJob
  queue_as :default

  def perform(photo_album)
    photo_album.images.each do |image|
      image.analyze
      return unless image.blob.metadata.include?("latitude") &&
        image.blob.metadata.include?("longitude")

      geocode = Geocoder.search(
        [image.blob.metadata['latitude'],
         image.blob.metadata['longitude']]
      )
      image.blob.metadata['geocode'] = geocode.first.data
      image.blob.save # This info is nice to have
    end
  end
end
