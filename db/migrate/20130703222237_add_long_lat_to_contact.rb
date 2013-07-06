class AddLongLatToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :long, :float
    add_column :contacts, :lat, :float

    add_index :contacts, [:long, :lat]
  end
end
