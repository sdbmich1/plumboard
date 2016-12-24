ThinkingSphinx::Index.define :promo_code, :with => :active_record do
  indexes :promo_name, :sortable => true
  indexes :code, :sortable => true
  indexes :description, :sortable => true
  indexes [site(:name)], :as => :site
  indexes [user(:business_name)], :as => :business
  indexes :site_id
  indexes :status

  has :id, :as => :promo_code_id 
  has owner_id, category_id
  where "(promo_codes.status = 'active') AND (promo_codes.end_date >= curdate()) " 
end

