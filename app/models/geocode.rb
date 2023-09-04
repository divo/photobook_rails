# frozen_string_literal: true
class Geocode < ApplicationRecord
  belongs_to :photo_album
  belongs_to :active_storage_blob, class_name: 'ActiveStorage::Blob'

  def to_h
    JSON.parse geocode
  end
end
