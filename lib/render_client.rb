class RenderClient
  include HTTParty
  # TODO: Error handling
  base_uri ENV['RENDER_APP_URL'] + ":" + ENV['RENDER_APP_PORT']

  # @param Hash
  def initialize(photo_album)
    @photo_album = photo_album
  end

  def ping
    self.class.get("/ping")
  end

  def render_album(job_id)
    # TODO: Create a record of the render request, an 'Order'
    ActiveStorage::Current.url_options = { host: "localhost:#{ENV.fetch('port', 3000)}" } # WHYYY
    options = @photo_album.merge(job_id: job_id)
    options[:size] = [230, 230]
    self.class.post("/api/render_album", body: options.to_json, headers: { 'Content-Type' => 'application/json' }, debug_output: $stdout )
  end
end
