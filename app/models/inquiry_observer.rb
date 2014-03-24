class InquiryObserver < ActiveRecord::Observer
  observe Inquiry

  # send emails upon request
  def after_create inquiry
    UserMailer.delay.send_inquiry(inquiry) # to user
    UserMailer.delay.send_inquiry_notice(inquiry) # to pixiboard
  end
end
