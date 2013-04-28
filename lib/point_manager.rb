module PointManager
  def self.add_points usr, cd
    usr.user_pixi_points.create code: cd
  end

  def self.calc_total_points usr
    usr.user_pixi_points.map {|p| p.pixi_point.value}.inject(0, :+)
  end
end
