module ProcessMethod
  include NameParse

  # get model attributes
  def self.get_attr model, arr
    attr = model.attributes
    arr.map {|x| attr.delete x}
    attr
  end

  # set guest user
  def self.set_guest_user model, usr, status
    if usr.id.blank?
      usr = User.new_guest
      if model.is_a?(TempListing)
        model.seller_id = usr.id
      else
        model.user_id = usr.id 
      end
      model.status = status
    end
    model
  end

  # set fields for main board
  def self.get_board_flds
    'listings.id, listings.title, listings.pixi_id, listings.seller_id,
     listings.price, listings.quantity, listings.site_id, listings.category_id,
     listings.job_type_code, listings.event_type_code, listings.description,
     listings.updated_at, listings.condition_type_code, listings.fulfillment_type_code'
  end

  # get host
  def self.get_host
    case Rails.env
    when 'test', 'development'; "localhost:3000"
    when 'demo', 'staging'; [Rails.env, PIXI_WEB_SITE].join('.')
    else PIXI_WEB_SITE
    end
  end

  # create unique url for user
  def self.generate_url klass, value, cnt=0
    begin
      value = NameParse::transliterate value, false, true
      new_url = cnt == 0 ? value.gsub(/\s+/, "") : [value.gsub(/\s+/, ""), cnt.to_s].join('')
      cnt += 1
    end while klass.constantize.where(:url => new_url).exists?
    new_url
  end

  # get full url string
  def self.get_url model, str
    str += '_url' if str
    Rails.application.routes.url_helpers.send(str, model, {host: get_host})
  end
end
