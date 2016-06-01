class CreatePlans < ActiveRecord::Migration
  def change
    create_table :plans do |t|
      t.string :name
      t.string :interval
      t.float :price
      t.string :status
      t.string :stripe_id
      t.integer :trial_days

      t.timestamps null: false
    end
    add_index :plans, :name
  end
end
