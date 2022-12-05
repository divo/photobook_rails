class RenderClient
  include HTTParty
  # TODO: Error handling
  base_uri ENV['RENDER_APP_URL'] + ":" + ENV['RENDER_APP_PORT']

  def initialize(photo_album)
    @photo_album = photo_album
  end

  def ping
    self.class.get("/ping")
  end

  def render_album(job_id)
    # TODO: Create a record of the render request, an 'Order'
    ActiveStorage::Current.url_options = { host: "localhost:#{ENV.fetch('port', 3000)}" } # WHYYY
    options = build_payload(job_id)
    self.class.post("/api/render_album", body: options.to_json, headers: { 'Content-Type' => 'application/json' }, debug_output: $stdout )
  end

  private

  def build_payload(job_id)
    {
      job_id: job_id,
      photo_album: @photo_album.id,
      cover: cover,
      pages: pages_payload
    }
  end

  def cover
    page_payload(@photo_album.images.first).merge({ name: @photo_album.name })
  end

  def pages_payload
    @photo_album.images.each_with_object([]) do |image, res|
      res << page_payload(image)
    end
  end

  def page_payload(image)
    {
      id: image.id,
      image_url: image.url,
      key: image.blob.key,
      content_type: image.blob.content_type
    }
  end
end
