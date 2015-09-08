ThinkingSphinx::Index.define :site, :with => :active_record do
  indexes name, :sortable => true
  indexes site_type_code
  indexes status

  has :id, :as => :site_id 
  where "(sites.status = 'active')"
end
