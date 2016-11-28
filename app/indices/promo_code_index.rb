ThinkingSphinx::Index.define :promo_code, :with => :active_record do
  indexes promo_name, :sortable => true
  indexes code
  indexes :description
  indexes [user(:business_name)], :as => :business

  has :id, :as => :promo_code_id 
  has :status
  where "(promo_codes.status = 'active') AND (promo_codes.end_date >= curdate()) " 
end

