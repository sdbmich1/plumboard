  require 'stripe'
  PMT_API_KEYS = YAML::load_file("#{Rails.root}/config/gateway.yml")[Rails.env]
  Stripe.api_key = PMT_API_KEYS['stripe']['api_key']
  STRIPE_PUBLIC_KEY = PMT_API_KEYS['stripe']['public_key']
  PIXI_FEE = PMT_API_KEYS['pixi']['fee']
  PIXI_PERCENT = PMT_API_KEYS['pixi']['percent']
