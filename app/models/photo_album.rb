class PhotoAlbum < ApplicationRecord
  include PhotoAlbumPresenter
  belongs_to :user
  has_many_attached :images
  validates :name, presence: true
  validate :min_images
  validate :max_images, on: :app
  after_save :broadcast_album_built

  def self.min_images
    5
  end

  def min_images
    if images.length < self.class.min_images
      errors.add :images, "Album must have at least #{self.class.min_images} images"
    end
  end

  # TODO: Surface this in UI
  def self.max_images
    200
  end

  def max_images
    if images.length > self.class.max_images
      errors.add :images, "Album must have at most 200 images"
    end
  end

  def broadcast_album_built
    if saved_changes['build_complete'] == [false, true]
      broadcast_action :build_complete
    end
  end

  def building?
    !build_complete
  end

  def set_cover(cover_id)
    cover_image = images.find { |x| x.blob['metadata']['cover'] == true }
    if cover_image.present?
      cover_image.blob.metadata['cover'] = false
      cover_image.save
    end

    new_cover_image = images.find { |x| x.id == cover_id.to_i }
    raise "Cover image not found" unless new_cover_image.present?
    new_cover_image.blob.metadata['cover'] = true
    new_cover_image.save
  end

  def delete_image(image_id)
    image = images.find { |x| x.id == image_id.to_i }
    raise "Image not found" unless image.present?
    image.destroy
  end
end
