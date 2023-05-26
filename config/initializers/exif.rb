# frozen_string_literal: true

module ActiveStorage
  class Analyzer::ImageAnalyzer < Analyzer
    def metadata
      read_image do |image|
        if rotated_image?(image)
          { width: image.height, height: image.width }
        else
          { width: image.width, height: image.height }
        end.merge(gps_from_exif(image) || {})
      end
    rescue LoadError
      logger.error "Skipping image analysis because the mini_magick gem isn't installed"
      {}
    end

    private

    def gps_from_exif(image)
      if (exif = Exif::Data.new(image.get_value('exif-data')))
        result = { date: exif.date_time }

        if exif.gps_latitude && exif.gps_longitude
          result.merge!({
            latitude: convert_coord(exif.gps_latitude),
            longitude: convert_coord(exif.gps_longitude)
          })
          result[:latitude] *= -1 if exif.gps_latitude_ref == 'S'
          result[:longitude] *= -1 if exif.gps_longitude_ref == 'W'
        end

        result
      end
    rescue ::Vips::Error, ::Exif::Error
      {}
    end

    def convert_coord(coord)
      coord[0].to_f + coord[1].to_f / 60 + coord[2].to_f / 3600
    end
  end
end
