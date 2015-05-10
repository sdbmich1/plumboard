ThinkingSphinx::Index.define :listing, :with => :active_record, :delta => true do
  indexes :title, :sortable => true
  indexes :description
  indexes [user(:first_name), user(:last_name)], :as => :name
<<<<<<< HEAD
  indexes [buyer(:first_name), buyer(:last_name)], :as => :buyer_name
  indexes user(:business_name), :as => :business
  indexes user(:url), :as => :url
=======
>>>>>>> issue-032-sdb

  has :id, :as => :listing_id 
  has category(:id), :as => :category_id
  has category(:name), :as => :category_name
  has site(:id), :as => :site_id
  has site(:name), :as => :site_name
  has :seller_id, :pixi_id, :created_at, :updated_at
  has price
  has :status
  has compensation
  has lat, lng
  where "(listings.status = 'active') AND (listings.end_date >= curdate()) " 
end
