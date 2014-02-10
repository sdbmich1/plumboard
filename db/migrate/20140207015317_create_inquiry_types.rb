class CreateInquiryTypes < ActiveRecord::Migration
  def change
    create_table :inquiry_types do |t|
      t.string :code
      t.string :inquiry_name
      t.string :status

      t.timestamps
    end
    add_index :inquiry_types, :code
  end
end
