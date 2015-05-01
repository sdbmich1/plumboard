# config/initializers/delayed_job
Delayed::Worker.backend = :active_record
Delayed::Worker.destroy_failed_jobs = true
Delayed::Worker.sleep_delay = 60
Delayed::Worker.max_attempts = 3
Delayed::Worker.max_run_time = 5.minutes
Delayed::Worker.delay_jobs = !Rails.env.test?

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