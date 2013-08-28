class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.integer :seller_id
      t.integer :user_id
      t.text :comments
      t.integer :value

      t.timestamps
    end
    
    add_index :ratings, [:seller_id, :user_id]
  end
end
