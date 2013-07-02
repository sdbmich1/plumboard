class Comment < ActiveRecord::Base
  attr_accessible :content, :user_id, :pixi_id

  belongs_to :user
  belongs_to :listing, foreign_key: "pixi_id", primary_key: "pixi_id"

  validates :content, :presence => true 
  validates :pixi_id, :presence => true
  validates :user_id, :presence => true

  default_scope order: 'comments.created_at DESC'

  # short content
  def summary
    descr = content.length < 30 ? content.html_safe : content.html_safe[0..29] rescue nil
    Rinku.auto_link(descr) if descr
  end

  # add hyperlinks to content
  def full_content
    Rinku.auto_link(content.html_safe) rescue nil
  end

  # check if content length > 30
  def long_content?
    content.length > 30 rescue nil
  end

  # get sender name
  def sender_name
    user.name if user
  end
end
