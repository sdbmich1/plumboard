class InquiryObserver < ActiveRecord::Observer
  observe Inquiry

  # send receipt upon request
  def after_create inquiry
    UserMailer.delay.send_inquiry(inquiry)
  end
end
