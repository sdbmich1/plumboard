# config file for pixi-specific api keys
PIXI_KEYS = YAML::load_file("#{Rails.root}/config/pixi_keys.yml")[Rails.env]

