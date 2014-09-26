class CreateEventTypes < ActiveRecord::Migration
  def change
    create_table :event_types do |t|
      t.string :code
      t.string :status
      t.string :hide
      t.string :description

      t.timestamps
    end
  end
end
