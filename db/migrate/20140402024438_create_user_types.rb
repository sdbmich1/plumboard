class CreateUserTypes < ActiveRecord::Migration
  def change
    create_table :user_types do |t|
      t.string :code
      t.string :description
      t.string :status

      t.timestamps
    end
    add_index :user_types, :code
  end
end
