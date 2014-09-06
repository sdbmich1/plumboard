class AddDupFlgToPictures < ActiveRecord::Migration
  def change
    add_column :pictures, :dup_flg, :boolean
  end
end
