class TempListingObserver < ActiveRecord::Observer
  observe TempListing

  def before_update model
    if model.status == 'approved'
      listing = Listing.find_by_pixi_id model.pixi_id

      # reset status if listing already exists
      model.status = 'edit' if listing
    end
  end

  # add listing to board and process transaction
  def after_update model
    case model.status
    when 'pending'
      UserMailer.delay.send_submit_notice(model)
    when 'approved'
      model.post_to_board
      model.transaction.process_transaction unless model.transaction.approved? rescue nil
    when 'denied'
      send_system_message model
      UserMailer.delay.send_denial(model)
    end
  end

  # send system message to user
  def send_system_message model
    SystemMessenger::send_message model.user, model, 'deny'
  end
end
