class AddCodeToPixiPoint < ActiveRecord::Migration
  def change
    add_column :pixi_points, :code, :string
    add_index :pixi_points, :code
  end
end
