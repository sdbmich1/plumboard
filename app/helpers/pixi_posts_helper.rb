module PixiPostsHelper

  # build child rows if they don't exist
  def setup_contact(person)
    (person).tap do |p|
      p.contacts.build if p.contacts.empty?
    end
  end

  # set path based on action
  def set_pixi_post_path
    if %w(edit show).detect {|x| action_name == x} 
      @post.owner?(@user) ? seller_pixi_posts_path(status: 'active') : pixi_posts_path(status: 'active') 
    else
      root_path
    end
  end

  # set pixi post menu name
  def set_pixi_post_menu
    if @post
      @post.owner?(@user) ? 'My PixiPosts' : 'PixiPosts'
    else
      'My PixiPosts'
    end
  end

  # define menu access
  def access_pxp_admin_menu?
    if %w(edit show).detect {|x| action_name == x} 
      !@post.owner?(@user)
    elsif action_name == 'index' && can?(:manage_items, @user)
      true
    else
      false
    end
    
  end
end
