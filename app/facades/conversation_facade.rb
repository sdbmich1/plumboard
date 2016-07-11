class ConversationFacade < AppFacade
  attr_reader :conversation

  def conversations user
    @conversations = Conversation.get_specific_conversations(user, status).paginate(page: params[:page], per_page: per_page)
  end

  def listing
    @listing = Listing.find_pixi params[:conversation][:pixi_id]
  end

  def comments
    @comments = listing.comments.paginate page: params[:page], per_page: PIXI_COMMENTS
  end

  def status
    params[:status] || 'received'
  end

  def per_page
    params[:per_page] || 10
  end
end

