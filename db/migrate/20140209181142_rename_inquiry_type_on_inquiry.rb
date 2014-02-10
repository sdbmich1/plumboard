class RenameInquiryTypeOnInquiry < ActiveRecord::Migration
  def up
    rename_column :inquiries, :inquiry_type, :code
  end

  def down
    rename_column :inquiries, :code, :inquiry_type
  end
end
