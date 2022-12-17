class PhotoAlbumPresenter < SimpleDelegator
  ActiveStorage::Current.url_options = { host: "localhost:#{ENV.fetch('port', 3000)}" } # WHYYY can't this be in application.rb

  SECTION_CLASS_TAG = 'section-page'

  # @param with_pages: If false only render the album cover
  # @param @block: Takes an ActiveStorage::Attachment and returns a URL. Views / API have different URL requirements
  def present(with_pages: true, &block)
    logger.info("Presenting data for #{self.id}")

    pages = with_pages ? build_entires(&block) : []
    pages = format_pages(pages)

    {
      photo_album: id,
      name: name,
      cover: cover(&block),
      pages: pages,
      magazine: true
    }.with_indifferent_access
  end

  private

  def cover(&block)
    entry(images.first, 'cover-page', &block).merge({ name: name })
  end

  def build_entires(&block)
    images.each_with_object([]) do |image, res|
      res << entry(image, &block)
    end
  end

  def entry(image, type = 'photo-content', &block)
    {
      id: image.id,
      image_url: block.call(image),
      key: image.blob.key,
      content_type: image.blob.content_type,
      address: format_address(image.blob.metadata['geocode']['address']),
      country: image.blob.metadata['geocode']['address']['country'],
      page_class: image.blob.metadata['section_page'] ? SECTION_CLASS_TAG : type,
      date: image.blob.metadata['date']
    }
  end

  # Different countries have different ideas of what makes an address
  # TODO: Handle no address object in geocode
  def format_address(address)
    logger.info('\n\n')
    logger.info(address)
    logger.info('\n\n')

    country= address['country']
    village = address['village'] ||
      address['hamlet'] ||
      address['town'] ||
      address['road'] ||
      address['locality'] ||
      address['city'] ||
      address['county'] ||
      address['state_district'] ||
      ''

    if village == ''
      logger.info("Could only find a country for #{address}")
      return country
    end

    village
  end

  def format_pages(pages)
    pages = sort_by_country(pages)
    remove_adjacent_addresses(pages)
  end

  def sort_by_country(pages)
    # TODO: Add a special case for America to sort by state
    # Sort by country, then place each section_page and the start of each group
    section_pages, content_pages = pages.partition { |page| page[:page_class] == SECTION_CLASS_TAG }

    content_pages.sort_by { |page| Date.parse(page[:date]) }

    section_pages = section_pages.group_by { |page| page[:country] }
    content_pages = content_pages.group_by { |page| page[:country] }

    section_pages.each do |key, value|
      value << content_pages[key]
    end
    section_pages.values.flatten
  end

  def remove_adjacent_addresses(pages)
    last_address = nil
    pages.each { |page|
      if last_address == page[:address]
        page[:address] = ''
      else
        last_address = page[:address]
      end
    }
  end

  def remove_duplicate_addresses(pages)
    seen_address = []
    pages.each { |page|
      if seen_address.include?(page[:address])
        page[:address] = ''
      else
        seen_address.push(page[:address])
      end
    }
  end
end
