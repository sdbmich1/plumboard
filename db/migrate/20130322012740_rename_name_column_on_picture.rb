class RenameNameColumnOnPicture < ActiveRecord::Migration
  def up
    rename_column :pictures, :name, :delete_flg
  end

  def down
    rename_column :pictures, :delete_flg, :name
  end
end
