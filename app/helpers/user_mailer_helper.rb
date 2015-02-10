module UserMailerHelper
  # test for enviroment
  def env_check
     ((Rails.env == 'development') || (Rails.env == 'staging') || (Rails.env == 'test'))? "[ TEST ]" : ""
  end

  # check for pixi approval type
  def approve_type listing, tFlg=true
    str = listing.repost_flg ? 'reposted' : 'approved' rescue 'approved'
    tFlg ? str.titleize : str 
  end

end
