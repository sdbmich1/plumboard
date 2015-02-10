module RatingsHelper
  # add new rating for user
  def setup_rating(user)
    rating = user.ratings.build 
  end
end
