class RenderClient
  include HTTParty
  # TODO: Error handling
  base_uri ENV['RENDER_APP_URL'] + ":" + ENV['RENDER_APP_PORT']

  # @param Hash
  def initialize(photo_album, spine_width)
    @photo_album = photo_album
    @spine_width = spine_width
  end

  def ping
    self.class.get("/ping")
  end

  def render_album(job_id)
    # TODO: Create a record of the render request, an 'Order'
    options = @photo_album.merge(job_id: job_id)
    options[:size] = [206, 206] # Passing the bleed here, doesn't scale correctly in the render app
    options[:spine_width] = @spine_width
    # TODO: Stop abusing long timeout. If I need to serve any level of
    # concurrency I need to use a queueing system, with something to
    # track and check job progress
    response = self.class.post("/api/render_album",
                    body: options.to_json,
                    headers: { 'Content-Type' => 'application/json' },
                    timeout: 60 * 60) # Allow render 5 minutes to complete
    Rails.logger.info "Rendered album #{job_id}"
    response
  end
end
