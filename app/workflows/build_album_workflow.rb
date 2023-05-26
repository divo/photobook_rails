class BuildAlbumWorkflow < Gush::Workflow
  def configure(photo_album_id)
    photo_album = PhotoAlbum.find(photo_album_id)

    run FormatJob, params: { photo_album_id: photo_album.id }

    # Need to pass indexs because FormatJob will replace any non-jpegs.
    # All that matters here is a GeocoderJob for each image
    # This is not greaaat though
    geocode_jobs = photo_album.images.each_with_index.map do |_image, index|
      run GeocoderJob, params: { photo_album_id: photo_album.id, idx: index }, after: FormatJob
    end

    run CoverSelectionJob, params: { photo_album_id: photo_album.id }, after: geocode_jobs

    run SectionImgJob, params: { photo_album_id: photo_album.id }, after: CoverSelectionJob

    run BuildCompleteJob, params: { photo_album_id: photo_album.id }, after: [SectionImgJob, FormatJob]

    run OrderEstimateJob, params: { photo_album_id: photo_album.id }, after: BuildCompleteJob
  end
end
