class CreateStockImages < ActiveRecord::Migration
  def change
    create_table :stock_images do |t|
      t.string :title
      t.string :category_type_code
      t.string :file_name

      t.timestamps
    end
  end
end
