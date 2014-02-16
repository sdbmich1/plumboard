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
    signed_in? ? @user.send(method) : ''
  end

end
