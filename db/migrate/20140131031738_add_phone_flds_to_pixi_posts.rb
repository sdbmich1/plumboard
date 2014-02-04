class AddPhoneFldsToPixiPosts < ActiveRecord::Migration
  def change
    add_column :pixi_posts, :home_phone, :string
    add_column :pixi_posts, :mobile_phone, :string
  end
end
