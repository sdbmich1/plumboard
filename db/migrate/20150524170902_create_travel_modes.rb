class CreateTravelModes < ActiveRecord::Migration
  def change
    create_table :travel_modes do |t|
      t.string :mode
      t.string :travel_type
      t.string :status
      t.string :hide
      t.string :description

      t.timestamps
    end
  end
end
