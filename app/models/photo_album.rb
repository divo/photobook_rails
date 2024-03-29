class PhotoAlbum < ApplicationRecord
  include PhotoAlbumPresenter
  belongs_to :user
  has_many_attached :images # TODO: Should this be dependent: :destroy?
  has_many :orders, dependent: :destroy
  has_one :order_estimate, dependent: :destroy, as: :estimateable
  validates :name, presence: true
  validate :min_images
  validate :max_images, on: :app
  before_save :update_final_page_count
  after_save :after_save_hook

  enum :build_status, %i(uploaded images_converted build_complete)

  def self.min_images
    30
  end

  def min_images
    if images.length < self.class.min_images
      errors.add :images, "Album must have at least #{self.class.min_images} images"
    end
  end

  # TODO: This is possibly a bigger issue. How to limit the no. of images before I know the number?
  def self.max_images
    150
  end

  def max_images
    if images.length > self.class.max_images
      errors.add :images, "Album must have at most #{PhotoAlbum.max_images} images"
    end
  end

  def after_save_hook
    if saved_changes['build_status'] == ["uploaded", "images_converted"]
      flow = BuildAlbumWorkflow.create(id)
      flow.start!
    elsif saved_changes['build_status'] == ["images_converted", "build_complete"]
      broadcast_action :build_complete
    end
  end

  def building?
    build_status != "build_complete"
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
    update_column(:final_page_count, calculate_final_page_count) if build_status == 'build_complete'
  end

  # Gelato requires the _content_ page count to create a quote
  # It does not count the cover spread and inside cover as content
  # This is not documented so posssibly incorrect
  def content_page_count
    calculate_final_page_count - 3
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
    count += 1 # Back cover and inside back cover
  end
end
