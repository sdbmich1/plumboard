class Comment < ActiveRecord::Base
  attr_accessible :content, :user_id, :pixi_id

  belongs_to :user
  belongs_to :listing, foreign_key: "pixi_id", primary_key: "pixi_id", touch: true

  validates :content, :presence => true 
  validates :pixi_id, :presence => true
  validates :user_id, :presence => true

  default_scope order: 'comments.created_at DESC'

  CONTENT_LENGTH = 40   # set comment display length

  # get pixis by category id
  def self.get_by_pixi pid, pg=1
    where(:pixi_id => pid).paginate page: pg, per_page: PIXI_COMMENTS
  end

  # short content
  def summary
    descr = content.length < CONTENT_LENGTH ? content.html_safe : content.html_safe[0..CONTENT_LENGTH-1] rescue nil
    Rinku.auto_link(descr) if descr
  end

  # add hyperlinks to content
  def full_content
    Rinku.auto_link(content.html_safe) rescue nil
  end

  # check if content length > CONTENT_LENGTH
  def long_content?
    content.length > CONTENT_LENGTH rescue nil
  end

  # get sender name
  def sender_name
    user.name if user
  end

  # set json string
  def as_json(options={})
    super(only: [:id, :user_id, :content, :created_at], methods: [:sender_name, :long_content?, :summary],
      include: {user: { only: [:first_name], methods: [:name, :photo] }})
  end
end
