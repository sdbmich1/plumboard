class ChangeInquiryNameColumn < ActiveRecord::Migration
  def up
    rename_column :inquiry_types, :inquiry_name, :subject
  end

  def down
    rename_column :inquiry_types, :subject, :inquiry_name
  end
end
