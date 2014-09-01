module PostsHelper

  # add new post for listing
  def setup_post(model)
    model ? model.posts.build : Post.new
  end

  # toggle msg sender or recipient based on send flg
  def set_poster post, sentFlg
    sentFlg ? post.recipient : post.user
  end

  # set read / unread icon
  def set_msg_icon post
    post.unread?(@user) ? 'pixi_blank16.png' : 'pixi_orange16.png'
  end

  # set read / unread icon
  def invoice_due? post
    post.due_invoice?(@user) && post.inv_msg? 
  end

  # set cache key based on invoice if found
  def cache_key_for_posts post
    if post.invoice
      "posts/#{post.id}-#{post.id}-#{post.invoice.updated_at.to_i}"
    else
      post
    end
  end

  # set mobile tab themes
  def get_theme val
    case action_name
     when 'index'
       val == 1 ? 'b' : 'd'
     when 'sent'
       val == 2 ? 'b' : 'd'
     when 'seller'
       val == 1 ? 'b' : 'd'
     when 'unposted'
       val == 2 ? 'b' : 'd'
     when 'sold'
       val == 3 ? 'b' : 'd'
     when 'received'
       val == 2 ? 'b' : 'd'
     when 'new'
       val == 3 ? 'b' : 'd'
     when 'contact'
       val == 2 ? 'b' : 'd'
     when 'password'
       val == 3 ? 'b' : 'd'
    end
  end
end
