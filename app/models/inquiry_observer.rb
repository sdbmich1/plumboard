class InquiryObserver < ActiveRecord::Observer
  observe Inquiry

  # send emails upon request
  def after_create inquiry
    UserMailer.send_inquiry(inquiry).deliver_later # to user
    UserMailer.send_inquiry_notice(inquiry).deliver_later # to pixiboard
  end
end
