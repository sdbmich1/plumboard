ThinkingSphinx::Index.define :post, :with => :active_record do
  indexes content

  has :id, :as => :post_id 
  has :pixi_id, :listing_id, :user_id, :recipient_id, :created_at, :updated_at
#  where "(posts.status = 'active')" 
end
