class RenderAlbumJob < ApplicationJob
  queue_as :default

  def perform(photo_album)
    # Do something later
    render_client = RenderClient.new(photo_album)
    # Wait for rendering to finish
    logger.info "Begin rendering album #{photo_album.id}"
    render_client.render_album(self.job_id)
    logger.info "Finished rendering album #{photo_album.id}"
    # then download the created album
  end
end
