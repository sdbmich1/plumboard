class PixiPoint < ActiveRecord::Base
  attr_accessible :action_name, :category_name, :value, :code

  has_many :user_pixi_points, foreign_key: :code, primary_key: :code
end
