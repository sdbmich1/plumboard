module PostsHelper

  # add new post for user
  def setup_post(usr)
    usr.posts.build
  end

  # toggle msg sender or recipient based on send flg
  def set_poster post, sentFlg
    sentFlg ? post.recipient : post.user
  end

  # set read / unread icon
  def set_msg_icon post
    post.unread?(@user) ? 'pixi_blank16.png' : 'pixi_orange16.png'
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
