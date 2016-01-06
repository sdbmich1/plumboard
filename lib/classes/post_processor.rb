class PostProcessor
  include NameParse

  def initialize post
    @post = post
  end

  # set active status
  def activate
    @post.status = 'active' if @post.status != 'removed'
    @post.recipient_status = 'active' if @post.recipient_status != 'removed'
    NameParse.encode_string @post.content  # check for invalid ascii chars
    @post
  end

  # short content
  def summary num, showTailFlg
    descr = @post.long_content?(num) ? @post.content.html_safe[0..num-1] : @post.content.html_safe rescue nil
    descr = showTailFlg ? descr + '...' : descr rescue nil
    Rinku.auto_link(descr) if descr
  end

  # add hyperlinks to content
  def full_content
    Rinku.auto_link(@post.content.html_safe) rescue nil
  end

  # add post for invoice creation or payment
  def add_post inv, listing, sender, recipient, msg, msgType=''
    sender && recipient ? add_message(listing, sender, recipient, msg, msgType) : false
  end

  # find the corresponding conversation
  def add_message listing, sender, recipient, msg, msgType
    conv = Conversation.get_conv listing.pixi_id, recipient.id, sender.id
    conv = add_conv(listing, sender, recipient) if conv.blank?
    conv.posts.create recipient_id: recipient.id, user_id: sender.id, msg_type: msgType, pixi_id: conv.pixi_id, content: msg
  end

  def add_conv listing, sender, recipient
    conv = Conversation.get_conv listing.pixi_id, sender.id, recipient.id
    conv = listing.conversations.create user_id: sender.id, recipient_id: recipient.id if conv.blank?
    conv
  end

  # send invoice post
  def send_invoice inv, listing
    !inv.blank? && !listing.blank? ? send_msg(inv, listing) : false
  end

  def send_msg inv, listing
    msg = "You received Invoice ##{inv.id} from #{inv.seller_name} for $" + ("%0.2f" % inv.amount)
    add_post inv, listing, inv.seller, inv.buyer, msg, 'inv'
  end

  def send_pay_msg inv, listing
    msg = "You received a payment for Invoice ##{inv.id} from #{inv.buyer_name} for $" + ("%0.2f" % inv.amount)
    add_post inv, listing, inv.buyer, inv.seller, msg, 'paidinv'
  end

  # pay invoice post
  def pay_invoice model
    inv = model.invoices[0] rescue nil
    listing = inv.listings.first if inv
    inv && listing ? send_pay_msg(inv, listing) : false
  end

  # check invoice status for buyer or seller
  def check_invoice usr, flg, fld
    if @post.listing && @post.listing.active?
      str = flg ? "buyer_id = #{@post.recipient_id}" : "buyer_id = #{@post.recipient_id} AND status = 'unpaid'"
      list = @post.listing.invoices.where(str)
      list.find_each do |invoice|
	result = flg ? invoice.owner?(usr) : !invoice.owner?(usr)
	if result && invoice.unpaid? && invoice.send(fld) == usr.name
	  invoice.invoice_details.find_each do |item|
	    return true if item.pixi_id == @post.pixi_id
	  end
	else
	  return false if invoice.paid?
	end
      end
      return flg ? (@post.listing.seller_id == usr.id && !list.any?) : false
    end
    false
  end

  # removes given posts for a specific user
  def remove_post user 
    if user.id == @post.user_id
      @post.update_attributes(status: 'removed')
    elsif user.id == @post.recipient_id 
      @post.update_attributes(recipient_status: 'removed')
    end
  end

  # map messages to conversations if needed
  def map_posts_to_conversations
    Post.order.reverse_order.each do |post|
      post.status = post.recipient_status = 'active'
      if post.conversation_id.nil?
    
        # finds if there is already an existing conversation for the post
        conv = Conversation.get_conv post.pixi_id, post.recipient_id, post.user_id

        # finds if there is existing conversation with swapped recipient/user
        if conv.blank?
          conv = Conversation.get_conv post.pixi_id, post.user_id, post.recipient_id
        end

        # create new conversation if one doesn't already exist
        if conv.blank?
          if listing = Listing.where(:pixi_id => post.pixi_id).first
            conv = listing.conversations.create pixi_id: post.pixi_id, user_id: post.user_id, recipient_id: post.recipient_id
	  end
        elsif conv.status != 'active' || conv.recipient_status != 'active'
          conv.status = conv.recipient_status = 'active'
          conv.save
        end

        # updates post with conversation id
        post.conversation_id = conv.id if conv
      end
      post.save
    end
  end
end
