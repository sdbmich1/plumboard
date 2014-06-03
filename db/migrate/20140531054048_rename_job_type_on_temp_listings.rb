class RenameJobTypeOnTempListings < ActiveRecord::Migration
  def up
    rename_column :temp_listings, :job_type, :job_type_code
    rename_column :listings, :job_type, :job_type_code
    rename_column :old_listings, :job_type, :job_type_code
  end

  def down
    rename_column :temp_listings, :job_type_code, :job_type
    rename_column :listings, :job_type_code, :job_type
    rename_column :old_listings, :job_type_code, :job_type
  end
end
