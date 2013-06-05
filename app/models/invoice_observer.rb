class InvoiceObserver < ActiveRecord::Observer
  observe Invoice
  include PointManager

  # update points
  def after_create model
    PointManager::add_points model.seller, 'inv' if model.seller
    send_post model
  end

  def after_update model
    send_post(model) if model.status == 'unpaid'
  end

  private

  # notify buyer
  def send_post model
    Post.send_invoice model, model.listing  
  end
end
