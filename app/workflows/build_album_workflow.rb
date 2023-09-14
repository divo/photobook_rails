class BuildAlbumWorkflow < Gush::Workflow
  def configure(photo_album_id)
    photo_album = PhotoAlbum.find(photo_album_id)

    run GeocoderJob, params: { photo_album_id: photo_album.id }

    run CoverSelectionJob, params: { photo_album_id: photo_album.id }, after: GeocoderJob

    run SectionImgJob, params: { photo_album_id: photo_album.id }, after: CoverSelectionJob

    run BuildCompleteJob, params: { photo_album_id: photo_album.id }, after: SectionImgJob

    run OrderEstimateJob, params: { photo_album_id: photo_album.id }, after: BuildCompleteJob
  end
end
