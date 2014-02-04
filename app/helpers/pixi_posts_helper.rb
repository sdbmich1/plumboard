module PixiPostsHelper

  # build child rows if they don't exist
  def setup_contact(person)
    (person).tap do |p|
      p.contacts.build if p.contacts.empty?
    end
  end
end
