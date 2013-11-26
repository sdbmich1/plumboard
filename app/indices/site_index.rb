ThinkingSphinx::Index.define :site, :with => :active_record do
  indexes name, :sortable => true

  has :id, :as => :site_id 
  where "(sites.status = 'active')"
end
