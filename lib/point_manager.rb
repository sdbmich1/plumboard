module PointManager

  # add points for user
  def self.add_points usr, cd
    usr.user_pixi_points.create code: cd
  end

  # calc points for given user
  def self.calc_total_points usr
    val = User.select("sum(`pixi_points`.`value`) AS total").joins(:user_pixi_points => :pixi_point).where('users.id' => usr.id)
       .group("`users`.`id`").first
    val.total
  end

  # returns top pixi users for given timeframe
  def self.daily_leaderboard dt=Date.yesterday, pg=1, rows=5

    # get pixi stars based on points accumulated for the day
    @stars = UserPixiPoint.where('user_pixi_points.created_at > ?', dt).group(:user_id).joins(:pixi_point).sum(:value)

    # sor descending by points
    @stars = Hash[@stars.sort_by{|k, v| v}.reverse]

    # get users 
    ulist = User.where(:id => @stars.map {|x| x[0]}).paginate :page=>pg, :per_page=>rows

    # resort users by points
    results = @stars.map{|id| ulist.detect{|each| each.id == id[0]}}
  end

  def self.get_points val
    @stars.select{|x| x == val}.first[1]
  end
end
