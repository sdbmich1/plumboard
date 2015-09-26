class Subdomain
  def self.matches?(request)
    request.subdomain.present? && request.subdomain == 'shoplocal' && match_env?
  end

  def self.match_env?
    Rails.env.test? || Rails.env.production? ? true : Rails.env.send("#{SLS_KEYS['home']['env']}")
  end
end
