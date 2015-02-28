class AddStatusToPixiWants < ActiveRecord::Migration
  def change
    add_column :pixi_wants, :status, :string
    add_index :pixi_wants, :status
  end
end
