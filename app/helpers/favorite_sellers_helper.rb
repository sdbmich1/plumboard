module FavoriteSellersHelper
  include LocationManager

  def favorite_sellers_partial(ftype, id)
    if id
      ftype == 'seller' ? 'shared/my_followers' : 'shared/my_sellers'
    else
      'shared/manage_followers'
    end
  end

  def favorite_sellers_menu_item(user)
    if user.is_business?
      link_to("My Followers", favorite_sellers_path(ftype: 'seller', id: user.id, status: 'active'), id: 'favor-link')
    else
      link_to("My Sellers", favorite_sellers_path(ftype: 'buyer', id: user.id, status: 'active'), id: 'favor-link')
    end
  end

  def follow_or_unfollow_button(status, user, seller, sz='')
    bcls = [(sz.blank? ? 'span2' : "btn-{sz} span1"), 'no-left'].join(' ')
    if seller.is_a?(User) && seller.is_business? && follow_action? && user.id != seller.id 
      toggle_follow_button status, user, seller, bcls
    end
  end

  def follow_action?
    !controller_name.match(/listings|favorite_sellers/).nil? && !%w(biz mbr create update).detect {|x| action_name == x}.nil? 
  end

  def toggle_follow_button status, user, seller, bcls  
    str = status == 'active' ? 'show_unfollow_button' : 'show_follow_button'
    render partial: "shared/#{str}", locals: { user: user, seller: seller, bcls: bcls }
  end

  def set_follow_path seller
    signed_in? ? favorite_sellers_path(seller_id: seller.id) : send("set_ask_path", seller.id)
  end

  def get_user_loc(user)
    user.primary_address || LocationManager::get_loc_name(nil, nil, user.home_zip)
  end
end
