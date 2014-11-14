class CreateConditionTypes < ActiveRecord::Migration
  def change
    create_table :condition_types do |t|
      t.string :code
      t.string :status
      t.string :hide

      t.timestamps
    end
  end
end
