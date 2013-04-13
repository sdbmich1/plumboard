class AddFbUserToUser < ActiveRecord::Migration
  def change
    add_column :users, :fb_user, :boolean
  end
end
