# config file for pixi-specific api keys
PIXI_KEYS = YAML::load_file("#{Rails.root}/config/pixi_keys.yml")[Rails.env]
PIXI_FEE = PIXI_KEYS['pixi']['fee']
PIXI_PERCENT = PIXI_KEYS['pixi']['percent']
PIXI_BASE_PRICE = PIXI_KEYS['pixi']['base_price']
PIXI_DAYS = PIXI_KEYS['pixi']['days']

