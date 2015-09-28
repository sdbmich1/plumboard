module UrlHelper

  def with_subdomain(subdomain)
    subdomain = (subdomain || "")
    subdomain += "." unless subdomain.empty?
    if subdomain.empty? && !Rails.env.match(/demo|staging/).nil?
      [Rails.env, '.', request.domain].join
    else
      [subdomain, request.domain].join
    end
  end

  def url_for(options = nil)
    if options.kind_of?(Hash) && options.has_key?(:subdomain)
      options[:host] = with_subdomain(options.delete(:subdomain))
    end
    super
  end
end
