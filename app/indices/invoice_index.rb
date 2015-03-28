ThinkingSphinx::Index.define :invoice, :with => :active_record, :delta => true do
  indexes [seller(:first_name), seller(:last_name)], :as => :seller_name
  indexes [buyer(:first_name), buyer(:last_name)], :as => :buyer_name
  indexes :comment
  indexes :status
  indexes listings(:title), :as => :title

  has :id, :as => :invoice_id 
  has :created_at, :updated_at
  has price 
  has sales_tax, ship_amt, amount
  where "(invoices.status != 'removed') "
end
