class GeocoderJob < ApplicationJob
  queue_as :default

  after_perform do |job|
    SectionImgJob.perform_later(job.arguments.first)
  end

  def perform(photo_album)
    photo_album.images.each do |image|
      image.analyze
      return unless image.blob.metadata.include?("latitude") &&
        image.blob.metadata.include?("longitude")

      # This is using nominatim (Open streetmap) by default.
      # TODO: Switch to a provider that allows more than 1 req/s
      geocode = Geocoder.search(
        [image.blob.metadata['latitude'],
         image.blob.metadata['longitude']]
      )
      image.blob.metadata['geocode'] = geocode.first.data

      # Hack: Treat US states like countires
      # I have to hack this here because I'm still using ActiveStorage::Attachments
      # and don't have a good way to add fields to this. I should really stop doing that
      if geocode.first.data['address']['country_code'] == 'us'
        image.blob.metadata['geocode']['address']['country'] = geocode.first.data['address']['state']
      end

      image.blob.save # This info is nice to have
    end
  end
end
