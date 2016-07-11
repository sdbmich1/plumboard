Pushwoosh.configure do |config|
  config.application = API_KEYS['pushwoosh']['app_id']
  config.auth = API_KEYS['pushwoosh']['api_key']
end
