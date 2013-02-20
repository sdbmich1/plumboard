namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    User.create(first_name: 'Joe', last_name: 'Blow', email: 'jblow@test.com', password: 'test#123', birth_date: 21.years.ago, gender: 'Male',
    password_confirmation: 'test#123')
    Site.create(name: 'College', status: 'active')
    Category.create(name: 'Sale', category_type: 'Sale', status: 'active')
    listing = Listing.create(title: 'Test Listing', description: 'Test', site_id: 1, seller_id: 1, category_id: 1, start_date: Time.now)
    picture = listing.pictures.build
    picture.photo = File.new Rails.root.join("spec", "fixtures", "photo.jpg")
    listing.save!
  end
end

