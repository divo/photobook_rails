class PhotoAlbumPresenter < SimpleDelegator
  SECTION_CLASS_TAG = 'section-page'

  # @param with_pages: If false only render the album cover
  # @param @block: Takes an ActiveStorage::Attachment and returns a URL. Views / API have different URL requirements
  def present(with_pages: true, &block)
    logger.info("Presenting data for #{self.id}")

    pages = with_pages ? build_entires(&block) : []
    pages = format_pages(pages) if with_pages

    {
      photo_album: id,
      name: name,
      cover: cover(&block),
      pages: pages,
      magazine: true
    }.with_indifferent_access
  end

  # This is no longer a presenter
  # TODO: Move this to some mixen so I can pretend I'm working with a class
  def set_cover(cover_id)
    cover_image = images.find { |x| x.blob['metadata']['cover'] == true }
    if cover_image.present?
      cover_image.blob.metadata['cover'] = false
      cover_image.save
    end

    new_cover_image = images.find { |x| x.id == cover_id.to_i }
    raise "Cover image not found" unless new_cover_image.present?
    new_cover_image.blob.metadata['cover'] = true
    new_cover_image.save
  end

  private

  def cover(&block)
    cover_image = images.find { |x| x.blob['metadata']['cover'] == true }
    cover_image = images.first if cover_image.nil?
    entry(cover_image, 'cover-page', &block).merge({ name: name })
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
      address: image.blob.metadata['geocode']&.fetch('address', nil) || '',
      country: image.blob.metadata['geocode']&.fetch('country', nil) || '',
      page_class: image.blob.metadata['section_page'] ? SECTION_CLASS_TAG : type,
      date: image.blob.metadata['date'] || Date.new(0).to_s # Some images don't have a date
    }
  end

  def format_pages(pages)
    pages = sort_by_country(pages)
    remove_adjacent_addresses(pages)
  end

  def sort_by_country(pages)
    # Sort by country, then place each section_page and the start of each group
    content_pages, section_pages = pages.partition { |page| page[:page_class] == 'photo-content' }
    # section_pages, content_pages = pages.partition { |page| page[:page_class] == SECTION_CLASS_TAG }
    section_pages = section_pages.group_by { |page| page[:country] }
    content_pages = content_pages.group_by { |page| page[:country] }

    # Insert section of nil country to capture photos without gps data
    # Place it at the start of the hash
    section_pages = {'' => []}.merge(section_pages) if content_pages[''].present?

    section_pages.each do |key, value|
      value << content_pages[key].sort_by { |x| Date.parse x[:date] }
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
