class CreateUserInterests < ActiveRecord::Migration
  def change
    create_table :user_interests do |t|
      t.integer :user_id
      t.integer :interest_id

      t.timestamps
    end

    add_index :user_interests, [:user_id, :interest_id], :unique=>true
  end
end
