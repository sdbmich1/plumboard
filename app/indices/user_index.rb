ThinkingSphinx::Index.define :user, :with => :active_record do
  indexes :first_name, :sortable => true
  indexes :last_name, :sortable => true
  indexes :email, :sortable => true
  indexes :business_name, :sortable => true
  indexes :url, :sortable => true

  has id, :as => :user_id
end

