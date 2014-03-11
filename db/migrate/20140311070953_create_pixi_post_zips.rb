class CreatePixiPostZips < ActiveRecord::Migration
  def change
    create_table :pixi_post_zips do |t|
      t.integer :zip
      t.string :city
      t.string :state
      t.string :status

      t.timestamps
    end
    add_index :pixi_post_zips, :zip
  end
end
