class AlbumValidator < ActiveModel::Validator
  def validate(record)
    if !record.name.present?
      record.errors.add :name, "The album must have a name"
    end

    if record.images.length < record.class.min_images
      record.errors.add :images, "Album must have at least #{record.class.min_images} images"
    elsif record.images.length > 200
      record.errors.add :images, "Album must have at most 200 images"
    end
  end
end

class PhotoAlbum < ApplicationRecord
  include Presentable
  include ActiveModel::Validations
  has_many_attached :images
  validates_with ::AlbumValidator

  def self.min_images
    5
  end
end
