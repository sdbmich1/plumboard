class ConversationProcessor
  include NameParse

  def initialize conv
    @conv = conv
  end

  # set active status
  def activate
    @conv.status = 'active' if @conv.status != 'removed'
    @conv.recipient_status = 'active' if @conv.recipient_status != 'removed'
    @conv
  end

  # checks if conv is a replied to message
  def replied_conv? usr
    if @conv.posts.count > 1 && @conv.posts.last.user_id != usr.id
      @conv.posts.each do |post|
        return true if post.user_id == usr.id
      end
    end
    false
  end

  # returns whether conversation has any associated unread posts
  def any_unread? usr
    @conv.posts.each do |post| 
      if post.unread?(usr) && post.recipient_id == usr.id
        return true
      end
    end
    return false
  end

  # check if user has a message in the conversation
  def usr_msg? convo, usr
    (usr.id == convo.user_id && convo.status == 'active') || (usr.id == convo.recipient_id && convo.recipient_status == 'active')
  end

  # get conversations where user has sent/received at least one message in conversation and conversation is active
  def get_specific_conversations usr, c_type 
    conv_ids = Array.new
    convos = Conversation.get_conversations(usr)
    convos.find_each do |convo|
      convo.posts.find_each do |post|
        if (c_type == "received" && post.recipient_id == usr.id && post.recipient_status == 'active') ||
           (c_type == "sent" && post.user_id == usr.id && post.status == 'active')
          conv_ids << convo.id if usr_msg?(convo, usr); break
        end
      end
    end
    return convos.where(["id in (?)", conv_ids]).sort_by {|x| x.posts.last.created_at }.reverse 
  end

  # sets convo status to 'removed'
  def remove_conv conv, user 
    if user.id == conv.user_id
      return update_status(conv, user, 'status')
    elsif user.id == conv.recipient_id 
      return update_status(conv, user, 'recipient_status')
    end
    false
  end

  # update appropriate status fld
  def update_status conv, user, fld
    if conv.update_attribute(fld.to_sym, 'removed')
      conv.remove_posts(user)
      true
    else
      false
    end
  end

  # sets all posts in a convo to 'removed'
  def remove_posts usr
    @conv.posts.each do |post|
      if usr.id == post.user_id
        post.status = 'removed'
      elsif usr.id == post.recipient_id
        post.recipient_status = 'removed'
      end
      post.save
    end
  end

  # mark all posts in a conversation
  def mark_all_posts usr
    return false if usr.blank?
    @conv.posts.each do |post|
      post.mark_as_read! for: usr if post
    end
  end

  # process request
  def add_want_request
    if @conv.status != 'removed' && @conv.recipient_status != 'removed'
      if @conv.posts.where('msg_type= ? AND status= ?', 'want', 'active').first
        @conv.user.pixi_wants.create(pixi_id: @conv.pixi_id, quantity: @conv.quantity,
          status: 'active', fulfillment_type_code: @conv.fulfillment_type_code)
      end
    end
  end

  def invoice_id
    inv = Invoice.get_by_status_and_pixi('unpaid', @conv.user.id, @conv.pixi_id).first if @conv.user
    inv.id if inv
  end
end
