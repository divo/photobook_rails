class PhotoAlbum < ApplicationRecord
  include Presentable
  has_many_attached :images
end
