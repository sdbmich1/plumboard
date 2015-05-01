module ProcessMethod

  # get model attributes
  def self.get_attr model, arr
    attr = model.attributes
    arr.map {|x| attr.delete x}
    attr
  end

  # set guest user
  def self.set_guest_user model, usr, status
    if usr.id.blank?
      usr = User.new_guest
      if model.is_a?(TempListing)
        model.seller_id = usr.id
      else
        model.user_id = usr.id 
      end
      model.status = status
    end
    model
  end
end
