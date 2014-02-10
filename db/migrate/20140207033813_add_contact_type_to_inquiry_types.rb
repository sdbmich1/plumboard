class AddContactTypeToInquiryTypes < ActiveRecord::Migration
  def change
    add_column :inquiry_types, :contact_type, :string
  end
end
