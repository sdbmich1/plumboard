module ConversationHelper

  # set font weight based on message status
  def set_font_weight model
    model.any_unread?(@user) && @status == 'received' ? 'font-bold' : '' rescue ''
  end

  # display timestamp
  def show_timestamp dt
    dt.to_date == Date.today ? short_time(dt) : short_date(dt) rescue short_time(Date.today)
  end

  # show message title
  def show_msg_title model
    if model
      msg_title = model.pixi_title
      msg_title = model.replied_conv?(@user) ? "RE: " + msg_title : msg_title
    end
  end

  # show messenger name and message count
  def show_msgr_name model
    cnt = model.active_post_count(@user) rescue 0
    msgs = cnt > 0 ? " (#{cnt})" : ""
    model.other_user(@user).name + msgs rescue nil
  end

  # check for existence
  def conv_exists? conversation
    !conversation.blank? && !conversation.listing.blank? && !conversation.posts.blank? rescue nil
  end

end
