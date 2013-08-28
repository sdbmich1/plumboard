class AddCountyToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :county, :string
    add_column :inquiries, :status, :string
  end
end
