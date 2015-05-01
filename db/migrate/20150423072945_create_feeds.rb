class CreateFeeds < ActiveRecord::Migration
  def change
    create_table :feeds do |t|
      t.integer :site_id
      t.string :site_name
      t.string :url
      t.string :status
      t.string :description

      t.timestamps
    end
    add_index :feeds, :site_id
  end
end
