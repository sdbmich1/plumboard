class PixiAskObserver < ActiveRecord::Observer
	observe PixiAsk
	include PointManager

	def after_create model
		#send notice to recipient
		UserMailer.delay.ask_question(model) if model.listing

		#reset saved pixi status
		SavedListing.update_status_by_user model.user_id, model.pixi_id, 'asked'

    	# update points
    	PointManager::add_points model.user, 'cs' if model.user
    end
end	
