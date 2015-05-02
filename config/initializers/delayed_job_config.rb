# config/initializers/delayed_job
Delayed::Worker.backend = :active_record
Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.sleep_delay = 60
Delayed::Worker.max_attempts = 3
Delayed::Worker.max_run_time = 5.minutes
Delayed::Worker.delay_jobs = !Rails.env.test?

Delayed::Worker.default_queue_name = 'default'

# to fix issue with uninitialized constant Syck::Syck error
# (see https://github.com/collectiveidea/delayed_job/issues/350)
class Module
  def yaml_tag_read_class(name)
    # Constantize the object so that ActiveSupport can attempt
    # its auto loading magic. Will raise LoadError if not successful.
    name.gsub!(/^YAML::/, '') if name =~ /BadAlias/
    name.constantize
    name
  end 
end

# Fail at startup if method does not exist instead of later in a background job 
if Rails.env.production? || Rails.env.staging?
  [[ExceptionNotifier::Notifier, :background_exception_notification]].each do |object, method_name|
    raise NoMethodError, "undefined method '#{method_name}' for #{object.inspect}" unless object.respond_to?(method_name, true)
  end
end

# Chain delayed job's handle_failed_job method to do exception notification
Delayed::Worker.class_eval do 
  def handle_failed_job_with_notification(job, error)
    handle_failed_job_without_notification(job, error)
    if Rails.env.production? || Rails.env.staging?
      # rescue if ExceptionNotifier fails for some reason
      begin
	ExceptionNotifier::Notifier.background_exception_notification(error).deliver
      rescue Exception => e
	Rails.logger.error "ExceptionNotifier failed: #{e.class.name}: #{e.message}"
	e.backtrace.each do |f|
	  Rails.logger.error "  #{f}"
	end
	Rails.logger.flush
      end
    end
  end 
  alias_method_chain :handle_failed_job, :notification 
end