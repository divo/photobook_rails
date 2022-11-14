class PhotoAlbum < ApplicationRecord
  has_many_attached :images
end
