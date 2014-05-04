ThinkingSphinx::Index.define :invoice, :with => :active_record do
  indexes :id, :sortable => true
  indexes listing(:title), :as => :title, :sortable => true
  indexes buyer(:last_name), :as => :buyer, :sortable => true
  indexes seller(:last_name), :as => :seller, :sortable => true

  has :buyer_id, :seller_id, :pixi_id, :amount, :status, :created_at, :updated_at
end

