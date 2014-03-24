module AddressManager

  # sets user address from another model
  def self.set_user_address usr, model
    @addr = usr.has_address? ? usr.contacts[0] : usr.contacts.build

    # update address
    synch_address @addr, model, true
  end

  # syncs address for any changes
  def self.synch_address addr, model, updateFlg=true
    changed = false
    %w(address address2 city state zip home_phone mobile_phone country).each do |method|
      if addr.send(method) != model.send(method)
	changed = true
      end
    end

    if changed
      addr.address, addr.address2 = model.address, model.address2
      addr.city, addr.state = model.city, model.state
      addr.zip, addr.home_phone, addr.mobile_phone, addr.country = model.zip, model.home_phone, model.mobile_phone, model.country 
      addr.save if updateFlg
    end
    addr
  end

  # display full address
  def self.full_address model
    addr = [model.address, model.city, model.state].compact.join(', ') rescue nil
    addr += ' ' + model.zip unless model.zip.blank?
    addr += ', ' + model.country unless model.country.blank?
    addr
  end
end

