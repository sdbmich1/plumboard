ThinkingSphinx::Index.define :temp_listing, :with => :active_record, :delta => true do
  indexes :title, :sortable => true
  indexes :description
  indexes [user(:first_name), user(:last_name)], :as => :name

  has :id, :as => :listing_id 
  has category(:id), :as => :category_id
  has site(:id), :as => :site_id
  has :pixi_id, :created_at, :updated_at
  has price
  has :status
  has compensation
  has lat, lng
  where "(temp_listings.status IN ('pending', 'edit', 'new'))"
end
