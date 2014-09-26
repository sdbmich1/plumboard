class CreateDateRanges < ActiveRecord::Migration
  def change
    create_table :date_ranges do |t|
      t.string :name
      t.string :status
      t.string :hide

      t.timestamps
    end
  end
end
