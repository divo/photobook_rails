class RenderAlbumJob < ApplicationJob
  queue_as :render_album

  def perform(photo_album, order, spine_width)
    # Do something later
    render_client = RenderClient.new(photo_album, spine_width)
    # Wait for rendering to finish
    logger.info "✅ Begin rendering album #{photo_album['id']}"

    begin
      response = render_client.render_album(self.job_id)
    rescue => e
      logger.error "⚠️ Error rendering album #{photo_album['id']}: #{e}"
      order.render_failed!
      return
    end

    if response.success?
      logger.info "✅ Finished rendering album #{photo_album['id']}"
      # Store the rendered album in the order
      save_rendered_album(order, response)

      order.render!
    else
      order.render_failed!
      raise "⚠️ Error rendering album #{photo_album['id']} with response #{response}"
    end
  end

  private

  def save_rendered_album(order, response)
    blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new(response.body),
      filename: "order_#{order.id}.pdf",
      service_name: :orders_bucket
    )
    blob.save!
    order.rendered_album.attach(blob)
    order.save!
  end
end
