class Photo < ApplicationRecord
  has_one_attached :image
  belongs_to :photo_album
end
