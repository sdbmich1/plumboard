module PicturesHelper
  # check for model errors
  def check_errors? listing
    listing.errors.any? rescue false
  end
end
