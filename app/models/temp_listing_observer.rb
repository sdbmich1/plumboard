class TempListingObserver < ActiveRecord::Observer
  observe TempListing

  def before_update model
    if model.status == 'approved'
      listing = Listing.find_by_pixi_id model.pixi_id

      #reset status if listing already exists
      model.status = 'edit' if listing
    end
  end

  # add listing to board and process transaction
  def after_update model
    if model.status == 'approved'
      model.post_to_board
      model.transaction.process_transaction unless model.transaction.approved? rescue nil
    end
  end
end
