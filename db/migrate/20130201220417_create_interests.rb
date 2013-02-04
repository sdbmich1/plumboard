class CreateInterests < ActiveRecord::Migration
  def change
    create_table :interests do |t|
      t.string :name
      t.string :status

      t.timestamps
    end

    add_index :interests, :name 
  end
end
