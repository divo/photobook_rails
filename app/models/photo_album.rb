#class AlbumValidator < ActiveModel::Validator
#  def validate(record)
#    require 'byebug'; byebug;
#    if !record.name.present?
#      record.errors.add :name, "The album must have a name"
#    end
#
#    if record.images.length < record.class.min_images
#      record.errors.add :images, "Album must have at least #{record.class.min_images} images"
#    elsif record.images.length > record.class.max_images
#      record.errors.add :images, "Album must have at most 200 images"
#    end
#  end
#end

class PhotoAlbum < ApplicationRecord
  include Presentable
  has_many_attached :images
  validates :name, presence: true
  validate :min_images
  validate :max_images, on: :app

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
    require 'byebug'; byebug;
    if images.length > self.class.max_images
      errors.add :images, "Album must have at most 200 images"
    end
  end
end
