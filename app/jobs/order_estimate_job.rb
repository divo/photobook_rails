class OrderEstimateJob < Gush::Job
  def perform
    photo_album = PhotoAlbum.find(params[:photo_album_id])
    user = photo_album.user
    order_client = OrderClient.new("#{photo_album.id}_estimate", user, photo_album.id)
    res = order_client.quote(photo_album.content_page_count)

    estimate = OrderEstimate.build_estimate(photo_album, res)
    estimate.save!

    photo_album.order_estimate = estimate
    photo_album.save
  end
end
