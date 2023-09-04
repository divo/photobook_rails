# frozen_string_literal: true

class String
  def is_i?
    !!(self =~ /\A[-+]?[0-9]+\z/)
  end
end

# Use GPS to pull place names from MapBox
class GeocoderJob < Gush::Job
  PLACE_TYPES = %w[address place region country].freeze

  def perform
    Rails.logger.info("[#{id} Starting Geocode for album: #{params[:photo_album_id]}")

    album = PhotoAlbum.find(params[:photo_album_id])
    album.images.each do |image|
      image.analyze

      Rails.logger.info("#{id} Geocode found image: #{image.id}")

      unless image.blob.metadata.include?('latitude') &&
             image.blob.metadata.include?('longitude')
        Rails.logger.error "#{self.id} Geocode #{params[:photo_album_id]}:#{params[:image_id]} No GPS data found"
        image.blob.metadata['geocode'] = { country: nil }
        image.blob.save
        return
      end

      # This is using nominatim (Open streetmap) by default.
      lat = image.blob.metadata.fetch('latitude')
      lng = image.blob.metadata.fetch('longitude')
      geocode = Geocoder.search([lat, lng])

      Rails.logger.error "#{id} Geocode #{self.class}: #{geocode.first.data}" if geocode.empty?

      geocode = extract_geocode_info(geocode)
      geo_record = Geocode.create(photo_album: album, active_storage_blob: image.blob, geocode: geocode.to_json, lat: lat, lng: lng)
      geo_record.save!
    end
  end

  private

  def extract_geocode_info(geocode)
    # Priority address - > place -> region -> country
    # There is no gaurentee what the response will contain
    # but it is ordered from most granular to least
    address = extract_principle_address(geocode, PLACE_TYPES)
    address_string = address.data['text']

    # If it's just a road number try again
    if address_string.chars.count(&:is_i?).to_f / address_string.chars.count > 0.5
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
    if %w[us gb].include?(country_code)
      country_string = region_string
    elsif address_string != region_string
      address_string = "#{address_string}, #{region_string}"
    end

    { address: address_string, country: country_string }
  end

  def extract_principle_address(geocode, types)
    geocode.find do |x|
      types.include?(x.data['place_type'].first)
    end
  end
end
