class AddQuantityToPixiWants < ActiveRecord::Migration
  def change
    add_column :pixi_wants, :quantity, :integer
  end
end
