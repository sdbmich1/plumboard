class AddPlaceToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :place, :string
  end
end
