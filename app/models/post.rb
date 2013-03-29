class Post < ActiveRecord::Base
  resourcify
  attr_accessible :content, :listing_id, :user_id

  belongs_to :user
  belongs_to :listing

  validates :content, :presence => true 
  validates :listing_id, :presence => true
  validates :user_id, :presence => true
end
