class BuildAlbumWorkflow < Gush::Workflow
  def configure(photo_album_id)
    photo_album = PhotoAlbum.find(photo_album_id)


    format_jobs = photo_album.images.map do |image|
      run FormatJob, params: { photo_album_id: photo_album.id, image_id: image.id }
    end

    run GeocoderJob, params: { photo_album_id: photo_album.id }, after: format_jobs

    run CoverSelectionJob, params: { photo_album_id: photo_album.id }, after: GeocoderJob

    run SectionImgJob, params: { photo_album_id: photo_album.id }, after: CoverSelectionJob

    run BuildCompleteJob, params: { photo_album_id: photo_album.id }, after: [SectionImgJob, FormatJob]

    run OrderEstimateJob, params: { photo_album_id: photo_album.id }, after: BuildCompleteJob
  end
end
