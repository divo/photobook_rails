class RenderAlbumJob < ApplicationJob
  queue_as :render_album

  def perform(photo_album, order, spine_width)
    # Do something later
    render_client = RenderClient.new(photo_album, spine_width)
    # Wait for rendering to finish
    logger.info "Begin rendering album #{photo_album['id']}"
    response = render_client.render_album(self.job_id)
    if response.success?
      logger.info "Finished rendering album #{photo_album['id']}"
      # Store the rendered album in the order
      blob = ActiveStorage::Blob.create_and_upload!(
        io: StringIO.new(response.body),
        filename: "order_#{order.id}.pdf",
        service_name: :orders_bucket
      )
      blob.save!
      order.rendered_album.attach(blob)
      order.save!

      order.render!
    else
      raise "Error rendering album #{photo_album['id']} with response #{response}"
      order.render_failed!
    end
    # then download the created album
  end
end
