class AddJobTypeToListings < ActiveRecord::Migration
  def change
    add_column :listings, :job_type, :string
    add_column :temp_listings, :job_type, :string
    add_column :old_listings, :job_type, :string
    add_index :listings, :job_type
  end
end
