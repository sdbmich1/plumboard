class TempListingObserver < ActiveRecord::Observer
  observe TempListing

  # add listing to board and process transaction
  def after_update model
    if model.status == 'approved'
      model.post_to_board
      model.transaction.process_transaction
    end
  end
end
