class AddDescriptionToConditionTypes < ActiveRecord::Migration
  def change
    add_column :condition_types, :description, :string
  end
end
