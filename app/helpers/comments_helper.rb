module CommentsHelper

  # set form header txt unless mobile device
  def get_comment_header
    "Comments (#{@listing.comments.count})"
  end

  # set form based on if mobile device
  def get_comment_form
    pname = [(mobile_device? ? 'mobile' : 'shared'), 'comment_form'].join('/')
  end
end
