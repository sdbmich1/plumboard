module PixiPostsHelper

  # build child rows if they don't exist
  def setup_contact(person)
    (person).tap do |p|
      p.contacts.build if p.contacts.empty?
    end
  end

  # add new details for pixi_post
  def setup_pixi_post(pixi_post)
    pixi_post.pixi_post_details.build if action_name == 'edit' && pixi_post.pixi_post_details.empty?
    pixi_post
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
    elsif action_name == 'pixter_report' && can?(:manage_items, @user)
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

  # test helper
  def pixter_report_total model
    @total = 0
    for elem in model
      @total += elem.sale_value if elem.any_sold?
    end
    @total
  end

  def grand_total model
    @total ||= pixter_report_total(model) 
    @total * PXB_TXN_PERCENT * PIXTER_PERCENT
  end

  # set image class
  def set_class
    action_name == "show" ? "usr-med-photo" : "myimage"
  end

  def load_dates 
    unless @xhr_flag 
      render :partial => 'shared/date_range_list'
    end
  end

  def load_admin_list
    render :partial => 'shared/get_pixter_list' if access_pxp_admin_menu? 
  end

  def pxp_title pid
    'Pixter Report for ' + (pid.blank? ? 'All Pixters' : User.find_by_id(pid).name)
  end

  def report_title title
    str = "#{@start_date.strftime('%m/%d/%Y')} to #{@end_date.strftime('%m/%d/%Y')}"
    content_tag(:div, content_tag(:h2, [title, str].join("<br>").html_safe), class: 'mtop center-wrapper mbot')
  end

  def get_post_val fld, post
    val = post.get_val(fld) 
    if val != 'Not sold yet' 
      fld == 'sale_date' ? post.get_date(fld) : ntc(val)
    end
  end

  def render_pxp_photo post
    action_name == 'seller' && @status != 'active' ? show_photo(post.pixan, 0, 'myimage', '80x80') : show_photo(post.user, 0, 'myimage', '80x80')
  end

  def render_name post
    name = action_name == 'seller' && @status != 'active' ? post.pixter_name : post.seller_name
    content_tag(:span, name, class:'mleft10')
  end

  def li_cls val
    @status == val ? 'active' : '' 
  end

  def menu_item title, id, cls, path, flg
    val = title == 'Pixter Report' ? false : remote?
    str = link_to(title, path, class: 'submenu', id: id, remote: val)
    content_tag(:li, str.html_safe, id: (flg ? 'li_home' : ''), class: li_cls(cls))
  end

  def show_pxp_menu_items str=[]
    str << menu_item('Completed', 'comp-posts', 'completed', pixi_posts_path(status: 'completed'), false)
    str << menu_item('Pixter Report', 'pixter-report', 'pixter_report', pixter_report_pixi_posts_path(status: 'pixter_report'), true)
    str
  end

  # load pixter report menu
  def pxp_menu
    content_tag(:ul, build_pxp_menu.join(" ").html_safe, class: 'nav') if signed_in?
  end

  # used to toggle pxp menu based on user
  def build_pxp_menu
    access_pxp_admin_menu? ? admin_pxp_menu : pixter_menu? ? pixter_pxp_menu : seller_pxp_menu
  end

  def pixter_menu?
    (@user.is_pixter? && can?(:manage_pixi_posts, @user))
  end

  def pixter_pxp_menu str=[]
    str << menu_item('Scheduled', 'schd-posts', 'scheduled', pixi_posts_path(status: 'scheduled'), true)
    show_pxp_menu_items str
    str
  end

  def admin_pxp_menu str=[]
    str << menu_item('Submitted', 'active-posts', 'active', pixi_posts_path(status: 'active'), true)
    str << menu_item('Scheduled', 'schd-posts', 'scheduled', pixi_posts_path(status: 'scheduled'), false)
    show_pxp_menu_items str
    str
  end

  def seller_pxp_menu str=[]
    str << menu_item('Submitted', 'active-posts', 'active', seller_pixi_posts_path(status: 'active'), true)
    str << menu_item('Scheduled', 'schd-posts', 'scheduled', seller_pixi_posts_path(status: 'scheduled'), false)
    str << menu_item('Completed', 'comp-posts', 'completed', seller_pixi_posts_path(status: 'completed'), false)
    str
  end

  def load_tr title, fld, str=[]
    str << content_tag(:td, title, class: 'span3')
    str << content_tag(:td, fld)
    str
  end

  def load_pp_details title, fld, post, str=[]
    content_tag(:tr, load_tr(title, fld).join('').html_safe) unless post.alt_date.blank?
  end

  def load_pp_response post, showAddrFlg
    render partial: 'shared/pixi_post_response', locals: {post: post, showAddrFlg: showAddrFlg} unless action_name == 'edit'
  end

  def show_ppd_header showAddrFlg
    content_tag(:h5, 'Request Information', class: 'grp-hdr') unless showAddrFlg 
  end

  def show_manage_pixi_post f, post
    render partial: 'shared/manage_pixi_post', locals: {post: post, f: f } if can?(:manage_items, @user) && action_name != 'new'
  end

  def show_pp_buttons post, str=[]
    str << link_to('Edit', edit_pixi_post_path(post), class: 'btn btn-large') if can_edit? post
    if (post.owner?(@user) || @user.is_admin?) && !post.is_completed?
      str << link_to('Remove', post, method: :delete, class: 'mleft10 btn btn-large', id: 'rm-btn', data: { confirm: 'Delete this PixiPost?' })
    end
    if post.owner?(@user) && !post.is_completed? && post.has_appt?
      str << link_to('Reschedule', reschedule_pixi_post_path(post), class: 'mleft10 btn btn-large', data: { confirm: 'Cancel this appointment?' })
    end
    str << link_to('Done', set_pixi_post_path, class: 'mleft10 btn btn-large btn-primary submit-btn')
    content_tag(:div, str.join('').html_safe, class: 'mtop pull-right')
  end
end
