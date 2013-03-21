class AddFeesToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :convenience_fee, :float
    add_column :transactions, :processing_fee, :float
  end
end
