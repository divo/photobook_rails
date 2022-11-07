json.extract! photo_album, :id, :name, :created_at, :updated_at
json.url photo_album_url(photo_album, format: :json)
