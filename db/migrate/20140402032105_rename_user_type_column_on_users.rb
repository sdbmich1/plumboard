class RenameUserTypeColumnOnUsers < ActiveRecord::Migration
  def up
    rename_column :users, :user_type, :user_type_code
  end

  def down
  end
end
