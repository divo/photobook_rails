class BuildAlbumWorkflow < Gush::Workflow
  def configure(photo_album_id)
    photo_album = PhotoAlbum.find(photo_album_id)

    geocoder_jobs = photo_album.images.map do |image|
      run GeocoderJob, params: { photo_album_id: photo_album.id, image_id: image.id }
    end

    run CoverSelectionJob, params: { photo_album_id: photo_album.id }, after: geocoder_jobs

    run SectionImgJob, params: { photo_album_id: photo_album.id }, after: CoverSelectionJob

    run BuildCompleteJob, params: { photo_album_id: photo_album.id }, after: SectionImgJob

    run OrderEstimateJob, params: { photo_album_id: photo_album.id }, after: BuildCompleteJob
  end
end
