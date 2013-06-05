  require 'balanced'
  BAL_API_KEYS = YAML::load_file("#{Rails.root}/config/gateway.yml")[Rails.env]
  BALANCED_API_KEY = BAL_API_KEYS['balanced']['api_key']
