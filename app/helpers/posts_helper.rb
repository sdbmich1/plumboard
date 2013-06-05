module PostsHelper

  # add new post for user
  def setup_post(usr)
    usr.posts.build
  end

  # toggle msg sender or recipient based on send flg
  def set_poster post, sentFlg
    sentFlg ? post.recipient : post.user
  end
end
