class FormatImagesWorkflow < Gush::Workflow
  def configure(photo_album_id)
    photo_album = PhotoAlbum.find(photo_album_id)

    format_jobs = photo_album.images.map do |image|
      run FormatJob, params: { photo_album_id: photo_album.id, image_id: image.id }
    end

    run FormatCompleteJob, params: { photo_album_id: photo_album.id }, after: format_jobs
  end
end
