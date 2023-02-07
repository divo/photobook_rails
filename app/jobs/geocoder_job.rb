class String
  def is_i?
    !!(self =~ /\A[-+]?[0-9]+\z/)
  end
end

class GeocoderJob < Gush::Job
  PLACE_TYPES = ['address', 'place', 'region', 'country']

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
    # Priority address - > place -> region -> country
    # There is no gaurentee what the response will contain
    # but it is ordered from most granular to least
    address = extract_principle_address(geocode, PLACE_TYPES)
    address_string = address.data['text']

    # If it's just a road number try again
    if address_string.chars.count { |x| x.is_i? }.to_f / address_string.chars.count > 0.5
      address = extract_principle_address(geocode, PLACE_TYPES.drop(1))
      address_string = address.data['text']
    end

    region = geocode.find { |x| x.data['place_type'].include?('region') }
    region_string = region.data['text']

    country = geocode.find { |x| x.data['place_type'].include?('country') }
    country_string = country.data['text']
    country_code = country.data['properties']['short_code']

    # Special case for US and GB because they are so big
    # `country` is used to create sections, the string is never displayed
    # For these Countries, the region is so big we can present them like
    # countries.
    if country_code == 'us' || country_code == 'gb'
      country_string = region_string
    elsif address_string != region_string
      address_string = address_string + ", " + region_string
    end

    { address: address_string, country: country_string }
  end

  def extract_principle_address(geocode, types)
    geocode.find do |x|
      types.include?(x.data['place_type'].first)
    end
  end
end
