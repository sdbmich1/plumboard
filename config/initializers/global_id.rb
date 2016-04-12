# Fix "Couldn't find MODEL_NAME with 'id'=" errors in ActiveJob
GlobalID::Locator.use Rails.application.railtie_name.remove("_application").dasherize do |gid|
  gid.model_class.find_by_id gid.model_id
end
