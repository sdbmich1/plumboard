class CreateFulfillmentTypes < ActiveRecord::Migration
  def change
    create_table :fulfillment_types do |t|
      t.string :code
      t.string :status
      t.string :hide
      t.string :description

      t.timestamps
    end
    add_index :fulfillment_types, :code
  end
end
