class GeocoderJob < Gush::Job
  # def perform
  #   param
  def perform
    image = PhotoAlbum.find(params[:photo_album_id]).images.find(params[:image_id])
    image.analyze

    return unless image.blob.metadata.include?("latitude") &&
      image.blob.metadata.include?("longitude")

    # This is using nominatim (Open streetmap) by default.
    # TODO: Switch to a provider that allows more than 1 req/s
    lat = image.blob.metadata.fetch("latitude")
    lng = image.blob.metadata.fetch("longitude")
    geocode = Geocoder.search([lat, lng])

    if geocode.empty?
      Rails.logger.error "#{self.class}: #{geocode.first.data}"
    end

    image.blob.metadata['geocode'] = extract_geocode_info(geocode)
    image.blob.save # This info is nice to have
  end

  private

  def extract_geocode_info(geocode)
    place = geocode.find { |x| x.data['place_type'].include?('place') }
    address = place.data['place_name'].split(',').take(2)

    country = place.data['context'].find { |x| x['id'].split('.').first == 'country' }
    country_name = country['text']
    country_code = country['short_code']
    if country_code == 'us' || country_code == 'gb'
      region = place.data['context'].find { |x| x['id'].split('.').first == 'region' }
      country_name = region['text']
      address = address.take(1) # Drop the redundant state name
    end

    address = address.join(',')
    { address: address, country: country_name }
  end
end
