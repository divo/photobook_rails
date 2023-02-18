class UploadMetadataWorkflow < Gush::Workflow
  def configure(photo_album_id)
    photo_album = PhotoAlbum.find(photo_album_id)

    geocode_jobs = photo_album.images.map do |image|
      run GeocoderJob, params: { photo_album_id: photo_album.id, image_id: image.id }
    end

    run CoverSelectionJob, params: { photo_album_id: photo_album.id }, after: geocode_jobs

    run SectionImgJob, params: { photo_album_id: photo_album.id }, after: CoverSelectionJob
  end
end
