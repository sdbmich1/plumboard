class CreateSavedListings < ActiveRecord::Migration
  def change
    create_table :saved_listings do |t|
      t.string :pixi_id
      t.integer :user_id

      t.timestamps
    end
    add_index :saved_listings, [:pixi_id, :user_id]
  end
end
