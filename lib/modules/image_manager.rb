require "open-uri"
require 'open_uri_redirections'
module ImageManager

  # parse image from web
  def self.parse_url_image pic, img
    pic.photo = URI.parse(process_uri(img)) 
    pic
  end

  # handle https uri requests
  def self.process_uri uri
    unless uri.blank?
      open(uri, :allow_redirections => :safe) do |r|
        r.base_uri.to_s
      end
    end
  end
end

