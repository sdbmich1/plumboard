class ChangeCommentsFldTypeOnRatings < ActiveRecord::Migration
  def up
    change_column :ratings, :comments, :text
  end

  def down
  end
end
