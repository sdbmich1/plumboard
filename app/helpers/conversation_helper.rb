module ConversationHelper

  # add new conversation for listing
  def setup_conversation(listing)
    conv = Conversation.get_conv(listing.pixi_id, listing.seller_id, @user.id) || Conversation.new
    conv.posts.build
    conv
  end

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

  # get posts
  def get_posts conv
    conv.posts.active_status(@user).reorder('created_at ASC') rescue nil if conv
  end

  # check if bill icon should show
  def show_bill_icon conv
    if conv.can_bill?(@user)
      content_tag(:td, link_to(image_tag('bill-icon.png'), get_invoice_path(conv.other_user(@user).id, conv.pixi_id, conv.id), 
	  class: 'btn btn-small', id: 'conv-bill-btn', title: 'Bill')) 
    end
  end

  def show_due_icon conv
    if conv.due_invoice?(@user)
      content_tag(:td, link_to(image_tag('pay-icon.png'), get_unpaid_path(conv.pixi_id, conv.id), class:'btn btn-small', id:'conv-pay-btn', title: 'Pay'), 
        align: 'right')
    end
  end

  def show_conversation conversation, sentFlg
    if conv_exists? conversation
      render partial: 'shared/show_conversation_details', locals: { conversation: conversation, sentFlg: sentFlg }
    else
      content_tag(:div, content_tag(:div, "No messages found.", class:'center-wrapper'), class: 'span12 sm-top')
    end
  end

  def show_reply conv, sentFlg
    content_tag(:div, render(partial: 'shared/reply', locals: { sentFlg: sentFlg, conversation: conv }), class: 'sm-top') unless conv.system_msg?
  end

  def check_due_icon conv
    show_due_icon conv unless conv.system_msg? 
  end

  def check_bill_icon conv
    show_bill_icon conv unless conv.system_msg?  
  end

  def render_conversation conversation
    render partial: 'shared/conversation_details', locals: { conversation: conversation } if conv_exists? conversation
  end
end
