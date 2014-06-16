ThinkingSphinx::Index.define :post, :with => :active_record do
  indexes content
  indexes [recipient(:first_name), recipient(:last_name)], :as => :recipient_name
  indexes [user(:first_name), user(:last_name)], :as => :sender_name
  indexes listing(:title), :as => :title, :sortable => true

  has :id, :as => :post_id 
  has pixi_id, user_id, recipient_id, created_at, updated_at
end
