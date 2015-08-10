# set lookup param
lookup = YAML::load_file("#{Rails.root}/config/pixi_keys.yml")[Rails.env]['geo_lookup'].to_sym

# set attributes
attr = {lookup: lookup, ip_lookup: :freegeoip, timeout: 30}

# set hash based on environment
attr.merge!(cache: Rails.cache) unless Rails.env.development? || Rails.env.test?

# initialize
Geocoder.configure(attr)
