module InquiriesHelper

  # toggle inquiry recipient
  def show_recipient 
    @source == 'support' && signed_in? ? "Pixiboard Support" : "Pixiboard Relations"
  end

  # toggle dropdown list based on type of inquiries
  def get_inquiry_type 
    @source == 'support' && signed_in? ? InquiryType.support : InquiryType.general
  end

  # set user info
  def get_info method
    if action_name == 'new'
      signed_in? ? @user.send(method) : ''
    else
      @inquiry.send(method) rescue ''
    end
  end

  # get sender name
  def get_sender_name
    action_name == 'new' ? @user.name : @inquiry.user_name
  end

  # set inquiry path based on action name
  def set_inquiry_path inquiry
    action_name == 'closed' ? inquiry : inquiry_path(inquiry, source: @code)
  end

end
