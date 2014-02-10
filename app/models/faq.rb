class Faq < ActiveRecord::Base
  attr_accessible :description, :question_type, :status, :subject
end
