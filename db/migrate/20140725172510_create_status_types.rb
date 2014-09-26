class CreateStatusTypes < ActiveRecord::Migration
  def change
    create_table :status_types do |t|
      t.string :code
      t.string :hide

      t.timestamps
    end
  end
end
