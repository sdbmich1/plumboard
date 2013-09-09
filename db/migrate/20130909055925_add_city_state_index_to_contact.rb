class AddCityStateIndexToContact < ActiveRecord::Migration
  def change
    add_index :contacts, [:city, :state]
  end
end
