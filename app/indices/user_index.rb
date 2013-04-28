ThinkingSphinx::Index.define :user, :with => :active_record do
  indexes :first_name
  indexes :last_name
  indexes :email, :sortable => true

  has id, :as => :user_id
end

