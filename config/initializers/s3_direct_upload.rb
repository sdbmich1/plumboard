S3DirectUpload.config do |c|
  AWS_KEYS = YAML::load_file("#{Rails.root}/config/aws.yml")[Rails.env]
  c.access_key_id = AWS_KEYS['access_key_id'] 
  c.secret_access_key = AWS_KEYS['secret_access_key'] 
  c.bucket = AWS_KEYS['bucket'] 
  c.region = 's3-' + AWS_KEYS['region'] 
  c.url = nil
end
