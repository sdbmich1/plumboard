class AddFulfillmentTypeCodeToPixiWants < ActiveRecord::Migration
  def change
    add_column :pixi_wants, :fulfillment_type_code, :string
    add_index :pixi_wants, :fulfillment_type_code
  end
end
