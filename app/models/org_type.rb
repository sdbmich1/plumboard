class OrgType < ActiveRecord::Base
  attr_accessible :code, :description, :hide, :status
  
  validates_presence_of :code, :description, :hide, :status

  #default scope

  # return active types
  def self.active
      where(:status => 'active')                              
  end
  
  # return all unhidden types
  def self.unhidden 
      active.where(:hide => 'no')
  end

  # titelize descr
  def nice_descr
      description.titleize rescue nil
  end   
end
