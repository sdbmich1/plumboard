class CreatePixiPosts < ActiveRecord::Migration
  def change
    create_table :pixi_posts do |t|
      t.integer :user_id
      t.datetime :preferred_date
      t.datetime :preferred_time
      t.datetime :alt_date
      t.datetime :alt_time
      t.datetime :appt_date
      t.datetime :appt_time
      t.datetime :completed_date
      t.datetime :completed_time
      t.string :pixi_id
      t.integer :pixan_id
      t.integer :quantity
      t.string :description
      t.float :value
      t.string :address
      t.string :city
      t.string :state
      t.string :zip

      t.timestamps
    end
    add_index :pixi_posts, :user_id
    add_index :pixi_posts, :pixan_id
    add_index :pixi_posts, :pixi_id
  end
end
