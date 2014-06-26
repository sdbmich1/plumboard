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
      @post.owner?(@user) ? seller_pixi_posts_path(status: 'active') : can?(:manage_items, @user) ? pixi_posts_path(status: 'active') : 
        pixter_pixi_posts_path(status: 'scheduled')
    else
      get_home_path
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
      !@post.owner?(@user) && !@user.is_pixter?
    elsif action_name == 'index' && can?(:manage_items, @user)
      true
    else
      false
    end
  end

  # get column header to match view type
  def get_col_header val
    case val
      when 'active'; 'Preferred'
      when 'scheduled'; 'Scheduled'
      when 'completed'; 'Completed'
    end
  end

  # get column header to match view type
  def get_name_header val
    val != 'active' && action_name == 'seller' ? 'Pixter' : 'Seller'
  end

  # get time value to match view type
  def get_col_time val, post
    case val
      when 'active'; tm = post.preferred_time
      when 'scheduled'; tm = post.appt_time
      when 'completed'; tm = post.completed_time
    end
    tm.strftime("%l:%M %p") rescue nil
  end

  # get date value to match view type
  def get_col_date val, post
    case val
      when 'active'; tm = post.preferred_date
      when 'scheduled'; tm = post.appt_date
      when 'completed'; tm = post.completed_date
    end
    get_local_date(tm) rescue nil
  end

  # check user can edit post
  def can_edit? post
    (post.owner?(@user) && !post.has_appt? && !post.is_completed?) || can?(:manage_items, @user)
  end 
end
