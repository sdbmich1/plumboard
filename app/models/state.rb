class State < ActiveRecord::Base
  attr_accessible :code, :state_name 

  # set json string
  def as_json(options={})
    super(only: [:code, :state_name])
  end
end
