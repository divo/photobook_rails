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

  def render_album()
    # TODO: Create a record of the render request, an 'Order'
    ActiveStorage::Current.url_options = { host: "localhost:#{ENV.fetch('port', 3000)}" } # WHYYY
    options = build_payload
    self.class.post("/api/render_album", body: options.to_json, headers: { 'Content-Type' => 'application/json' }, debug_output: $stdout )
  end

  private

  def build_payload()
    {
      photo_album: @photo_album.id,
      pages: pages_payload
    }
  end

  def pages_payload
    @photo_album.images.each_with_object([]) do |image, res|
      res << { id: image.id, image_url: image.url }
    end
  end
end
