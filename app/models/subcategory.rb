class Subcategory < ActiveRecord::Base
  attr_accessible :category_id, :name, :status, :subcategory_type, :pictures_attributes

  belongs_to :category

  has_many :pictures, :as => :imageable, :dependent => :destroy
  accepts_nested_attributes_for :pictures, :allow_destroy => true, :reject_if => :all_blank

  validates :category_id, :presence => true
  validates :name, :presence => true
  validates :status, :presence => true
  validates :subcategory_type, :presence => true
  validate :must_have_picture

  default_scope { order "name ASC" }

  # validate picture exists
  def must_have_picture
    if !any_pix?
      errors.add(:base, 'Must have a picture')
      false
    else
      true
    end
  end

  # used to add pictures for new category
  def with_picture
    self.pictures.build if self.pictures.blank?
    self
  end

  # check for a picture
  def any_pix?
    pictures.detect { |x| x && !x.photo_file_name.nil? }
  end

  # return active categories
  def self.active
    where(:status => 'active')
  end

  # return inactive categories
  def self.inactive
    where(:status => 'inactive')
  end
end
