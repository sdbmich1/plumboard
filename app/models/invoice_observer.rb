class InvoiceObserver < ActiveRecord::Observer
  observe Invoice
  include PointManager

  # update points
  def after_create model
    PointManager::add_points model.seller, 'inv' if model.seller

    # send post
    send_post model
  end

  def after_update model
    # send post
    send_post(model) if model.status == 'unpaid'

    # toggle status
    if model.status == 'paid'
      mark_pixi(model) 

      # credit seller account
      model.credit_account
    end
  end

  private

  # notify buyer
  def send_post model
    Post.send_invoice model, model.listing  
  end

  # mark pixi as sold
  def mark_pixi model
    model.listing.mark_as_sold 
  end
end
