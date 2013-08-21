ActionMailer::Base.delivery_method = :smtp

# set user and password
yml = YAML::load_file("#{Rails.root}/config/sendmail.yml")[Rails.env]
uname, pwd, domain, host_url, smtp_addr = yml['user_name'], yml['password'], yml['domain'], yml['host'], yml['smtp_addr']

# set smtp parameters
smtp_settings = {
  :address              => smtp_addr,
  :port                 => 587,
  :domain               => domain,
  :user_name            => uname,
  :password             => pwd,
  :authentication       => "plain",
  :enable_starttls_auto => true
}

# set vars    
ActionMailer::Base.smtp_settings = smtp_settings
ActionMailer::Base.default_url_options[:host] = host_url
