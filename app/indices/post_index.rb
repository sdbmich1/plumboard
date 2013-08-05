ThinkingSphinx::Index.define :post, :with => :active_record do
  indexes content
  indexes recipient(:first_name), :as => :first_name, :sortable => true
  indexes recipient(:last_name), :as => :last_name, :sortable => true
  indexes listing(:title), :as => :title, :sortable => true

  has :id, :as => :post_id 
  has :pixi_id, :listing_id, :user_id, :recipient_id, :created_at, :updated_at
end
