Geocoder.configure(
  # geocoding service (see below for supported options):
  :lookup => YAML::load_file("#{Rails.root}/config/pixi_keys.yml")[Rails.env]['geo_lookup'].to_sym,
  :ip_lookup => :freegeoip,  # IP address lookup support
  :cache => Rails.cache,
  :timeout => 30
)
