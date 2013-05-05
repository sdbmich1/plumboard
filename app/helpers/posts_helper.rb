module PostsHelper

  def setup_post(usr)
    usr.posts.build
  end
end
