class AddPixiIdToRating < ActiveRecord::Migration
  def change
    add_column :ratings, :pixi_id, :string
    add_index :ratings, :pixi_id
  end
end
