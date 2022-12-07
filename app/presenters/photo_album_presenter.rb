class PhotoAlbumPresenter < SimpleDelegator
  ActiveStorage::Current.url_options = { host: "localhost:#{ENV.fetch('port', 3000)}" } # WHYYY can't this be in application.rb

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
    entry(images.first, &block).merge({ name: name })
  end

  def build_entires(&block)
    images.each_with_object([]) do |image, res|
      res << entry(image, &block)
    end
  end

  def entry(image, &block)
    {
      id: image.id,
      image_url: block.call(image),
      key: image.blob.key,
      content_type: image.blob.content_type,
      address: image.blob.metadata['geocode']['address']['road'] + ', ' + image.blob.metadata['geocode']['address']['country']
    }
  end

  def format_pages(pages)
    # TODO: sort by country
    remove_duplicate_addresses(pages)
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
