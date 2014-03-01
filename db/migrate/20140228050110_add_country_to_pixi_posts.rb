class AddCountryToPixiPosts < ActiveRecord::Migration
  def change
    add_column :pixi_posts, :country, :string
  end
end
