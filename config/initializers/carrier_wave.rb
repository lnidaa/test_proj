CarrierWave.configure do |config|
  config.fog_credentials = {
      # Настройка для Amazon S3
      :provider => 'AWS',
      :aws_access_key_id => ENV['AWS_ACCESS_KEY_ID'],
      :aws_secret_access_key => ENV['AWS_SECRET_ACCESS_KEY'],
      :region => ENV['REGION_AWS']
  }
  config.fog_directory = 'mytestikbucket'
end

