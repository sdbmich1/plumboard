ActionMailer::Base.delivery_method = :smtp

# toggle based on Rails environment
if Rails.env.development? 
  smtp_settings = {
      :address              => "smtp.gmail.com",
      :port                 => 587,
      :domain               => "gmail.com",
      :user_name            => "sdbmich1@gmail.com",
      :password             => "sdb91mse",
      :authentication       => "plain",
      :enable_starttls_auto => true
    }
  host_url = Rails.env.development? ? "localhost:3000" : "www.pixiboard.com"
else
  smtp_settings = {  
    :address              => "smtpout.secureserver.net",  
    :port                 => 3535,  
    :user_name            => "info@pixiboard.com",  
    :password             => "piXi#123",
    :domain               => "pixiboard.com",
    :authentication       => "plain"
    } 
  host_url = "www.pixiboard.com"
end

# set vars    
ActionMailer::Base.smtp_settings = smtp_settings
ActionMailer::Base.default_url_options[:host] = host_url
