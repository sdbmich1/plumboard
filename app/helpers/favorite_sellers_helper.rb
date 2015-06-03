module FavoriteSellersHelper
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

  def follow_or_unfollow_button(status, user, seller)
    if status == 'active'
      link_to('Unfollow', favorite_seller_path(id: user.favorite_seller_id(seller.id), seller_id: seller.id),
                :method => :put, id: 'unfollow-btn', class: 'btn btn-small btn-primary', remote: true)
    else
      link_to('Follow', favorite_sellers_path(seller_id: seller.id),
                      id: 'follow-btn', class: 'btn btn-small submit-btn', remote: true)
    end
  end

  def get_user_loc(user)
    user.primary_address || user.home_zip
  end
end
