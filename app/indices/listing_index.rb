ThinkingSphinx::Index.define :listing, :with => :active_record do
  indexes :title, :sortable => true
  indexes :description
#  indexes seller_name, :as => :seller

  has :id, :as => :listing_id 
  has category(:id), :as => :category_id
  has site(:id), :as => :site_id
  has :pixi_id, :created_at, :updated_at
  has price
  has compensation
  has lat, lng
  where "(listings.status = 'active')" 
end
