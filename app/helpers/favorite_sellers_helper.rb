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
    if seller.is_business? && controller_name.match(/users/).nil? && !%w(biz member).detect {|x| action_name == x}.nil? 
      if status == 'active'
        link_to('- Unfollow', favorite_seller_path(id: user.favorite_seller_id(seller.id), seller_id: seller.id),
                :method => :put, id: "unfollow-btn", class: "btn btn-primary #{bcls} bold-btn", remote: true)
      else
        link_to('+ Follow', set_follow_path(seller), method: :post,
                id: "follow-btn", class: "btn btn-primary #{bcls} submit-btn", remote: true, title: "Follow this seller")
      end
    end
  end

  def set_follow_path seller
    signed_in? ? favorite_sellers_path(seller_id: seller.id) : send("set_ask_path", seller.id)
  end

  def get_user_loc(user)
    user.primary_address || LocationManager::get_loc_name(nil, nil, user.home_zip)
  end
end
