class CreateUserPixiPoints < ActiveRecord::Migration
  def change
    create_table :user_pixi_points do |t|
      t.integer :user_id
      t.string :code

      t.timestamps
    end

    add_index :user_pixi_points, [:user_id, :code, :created_at]
  end
end
