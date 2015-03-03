class InvoiceObserver < ActiveRecord::Observer
  observe Invoice
  include PointManager, CalcTotal

  # update points
  def after_create model
    PointManager::add_points model.seller, 'inv' if model.seller

    # send post
    send_post model
  end

  def after_update model
    fee = 0.0

    # send post
    send_post(model) if model.unpaid?

    # toggle status
    if model.paid?
      mark_pixi(model) 

      # credit seller account
      if model.amount > 0
	fee = model.get_convenience_fee
        result = model.bank_account.credit_account(model.amount - fee) rescue nil

        # record payment
	if result
	  PixiPayment.add_transaction(model, fee, result.uri, result.id) rescue nil

          # send receipt upon approval
          # UserMailer.delay.send_payment_receipt(model, result)
          UserMailer.send_payment_receipt(model, result).deliver rescue nil
	end
      end
    end
  end

  private

  # notify buyer
  def send_post model
    Post.send_invoice model, model.listings.first if model.listings 
  end

  # mark pixi as sold
  def mark_pixi model
    model.listings.find_each do |listing|
      listing.mark_as_sold 

      # mark want as sold
      PixiWant.set_status(listing.pixi_id, model.buyer_id, 'sold')
    end
  end
end
