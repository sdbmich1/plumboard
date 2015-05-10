ThinkingSphinx::Index.define :pixi_payment, :with => :active_record do
  indexes :transaction_id, :sortable => true
  indexes buyer(:last_name), :as => :buyer, :sortable => true
  indexes seller(:last_name), :as => :seller, :sortable => true
  indexes confirmation_no, :sortable => true

  has :buyer_id, :seller_id, :amount, :pixi_fee, :invoice_id, :created_at, :updated_at
end


