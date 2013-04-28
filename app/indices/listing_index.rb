ThinkingSphinx::Index.define :listing, :with => :active_record do
  indexes :title, :sortable => true
  indexes :description
#  indexes seller_name, :as => :seller
  indexes category(:name), :as => :category

  has :id, :as => :listing_id 
  has :pixi_id, :created_at, :updated_at
  where "(listings.status = 'active')" 
end
