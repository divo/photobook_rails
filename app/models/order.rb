class Order < ApplicationRecord
  belongs_to :photo_album
  belongs_to :order_estimate # This should be a clone of the PhotoAlbum's OrderEstimate, as to lock it in time
end
