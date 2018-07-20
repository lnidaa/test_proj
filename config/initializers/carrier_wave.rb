CarrierWave.configure do |config|
  config.fog_credentials = {
      # Настройка для Amazon S3
      :provider => 'AWS',
      :aws_access_key_id => 'AKIAIBI7KS22IIUIW7EQ',
      :aws_secret_access_key => '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',
      :region => 'us-east-2'
  }
  config.fog_directory = 'mytestikbucket'
end

