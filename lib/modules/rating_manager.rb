module RatingManager

  # calc total rating sum for given user
  def self.total_rating usr
    val = Rating.select("sum(`ratings`.`value`) AS total").where(:seller_id => usr.id).group(:seller_id).first rescue 0
    val.total rescue 0
  end

  # calc avg rating for given user
  def self.avg_rating usr
    val = Rating.select("avg(`ratings`.`value`) AS total").where(:seller_id => usr.id).group(:seller_id).first rescue 0
    val.total.to_f.round(1) rescue 0
  end
end
