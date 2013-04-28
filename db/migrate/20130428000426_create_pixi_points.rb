class CreatePixiPoints < ActiveRecord::Migration
  def change
    create_table :pixi_points do |t|
      t.integer :value
      t.string :action_name
      t.string :category_name

      t.timestamps
    end
  end
end
