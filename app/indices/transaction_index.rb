ThinkingSphinx::Index.define :transaction, :with => :active_record do
  indexes :first_name, :sortable => true
  indexes :last_name, :sortable => true
  indexes :email, :sortable => true
  indexes :confirmation_no, :sortable => true
  indexes :description, :sortable => true
  indexes :payment_type

  has :id, :home_phone, :created_at, :updated_at, :amt, :status, :convenience_fee
end

