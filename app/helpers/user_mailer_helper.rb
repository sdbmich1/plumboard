module UserMailerHelper
  # test for enviroment
  def env_check
     !Rails.env.production? ? "[ TEST ]" : ""
  end

  # check for pixi approval type
  def approve_type listing, tFlg=true
    str = listing.repost_flg ? 'reposted' : 'approved' rescue 'approved'
    tFlg ? str.titleize : str 
  end

end
