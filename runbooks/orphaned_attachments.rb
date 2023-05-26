s3 = Aws::S3::Resource.new({
  region: "eu-west-1",
  access_key_id: Rails.application.credentials.dig(:aws, :access_key_id),
  secret_access_key: Rails.application.credentials.dig(:aws, :secret_access_key)
})

# List bucket contents
s3_bucket = s3.bucket("divo-photobook-bucket") 
s3_keys = s3_bucket.objects(prefix:'', delimiter: '').map(&:key)

# List active storage attachments
as_keys = ActiveStorage::Attachment.all.map(&:key)

s3_oprhans = s3_keys - as_keys
as_orphans = as_keys - s3_keys

s3_oprhans.each do |key|
  s3_bucket.objects(prefix:'', delimiter: '').to_a.first { |x| x.key == key }.delete
end

as_orphans.each do |key|
  ActiveStorage::Attachment.all.find { |x| x.key == key }.delete
end
