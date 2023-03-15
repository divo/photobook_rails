class PhotoAlbum < ApplicationRecord
  include PhotoAlbumPresenter
  belongs_to :user
  has_many_attached :images
  has_one :order_estimate, dependent: :destroy
  validates :name, presence: true
  validate :min_images
  validate :max_images, on: :app
  before_save :update_final_page_count
  after_save :broadcast_album_built

  def self.min_images
    1
  end

  def min_images
    if images.length < self.class.min_images
      errors.add :images, "Album must have at least #{self.class.min_images} images"
    end
  end

  # TODO: Surface this in UI
  def self.max_images
    180
  end

  def max_images
    if images.length > self.class.max_images
      errors.add :images, "Album must have at most #{PhotoAlbum.max_images} images"
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

    new_cover_image = images.find { |x| x.id == cover_id }
    raise "Cover image not found" unless new_cover_image.present?
    new_cover_image.blob.metadata['cover'] = true
    new_cover_image.save
  end

  def delete_image(image_id)
    image = images.find { |x| x.id == image_id }
    raise "Image not found" unless image.present?
    image.destroy
  end

  def update_final_page_count
    update_column(:final_page_count, calculate_final_page_count) if build_complete
  end

  # Mirror of logic in Node rendering app to bulk out with empty pages
  # The equality opertions might look backwards compared to the JS, but
  # that's because JS is a deceptive piece of shit
  def calculate_final_page_count
    count = 2 # Cover and inside cover

    json_album = present { |i| '' }
    json_album[:pages].each do |page|
      if page[:page_class] == 'section-page'
        if (count % 2) == 0
          count += 1
        end
        count += 1
      end

      count += 1
    end

    if (count % 2) != 0
      count += 1
    end
    count += 2 # Back cover and inside back cover
  end
end
