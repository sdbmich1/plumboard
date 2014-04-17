class ListingObserver < ActiveRecord::Observer
  observe Listing
  include PointManager, SystemMessenger

  # update points
  def after_create model
    ptype = model.premium? ? 'app' : 'abp'
    PointManager::add_points model.user, ptype if model.user

    # remove temp pixi
    delete_temp_pixi model

    # send system message to user
    send_system_message model

    # send approval message
    UserMailer.delay.send_approval(model)
  end

  def after_update model
    delete_temp_pixi model

    # mark saved pixis if sold or closed
    if model.sold? || model.closed? || model.inactive?
      SavedListing.update_status model.pixi_id, model.status
    end
  end

  # remove temp pixi
  def delete_temp_pixi model
    TempListing.where(:pixi_id => model.pixi_id).destroy_all
  end

  # send system message to user
  def send_system_message model
    SystemMessenger::send_message model.user, model, 'approve'
  end
end
