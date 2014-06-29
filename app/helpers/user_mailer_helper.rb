module UserMailerHelper
  # test for enviroment
  def env_check
     ((Rails.env == 'development') || (Rails.env == 'staging') || (Rails.env == 'test'))? "[ TEST ]" : ""
  end

end