require 'spec_helper'

feature "Categories" do
  subject { page }

  before(:each) do
    @category = FactoryGirl.create :category
    FactoryGirl.create :category, name: 'Computer', category_type: 'sales', status: 'active'
    FactoryGirl.create :category, name: 'Stuff', category_type: 'sales', status: 'inactive'
  end

  def user_login
    login_as(user, :scope => :user, :run_callbacks => false)
    @user = user
  end

  def add_data_w_photo
    attach_file('user_pic', Rails.root.join("spec", "fixtures", "photo.jpg"))
    sleep 2
  end

  describe "Show Categories" do 
    let(:user) { FactoryGirl.create :admin, first_name: 'Jack', last_name: 'Snow', email: 'jack.snow@pixitest.com', confirmed_at: Time.now }

    before do
      user_login
      visit manage_categories_path 
    end

    it { should have_content('Categories') }
    it { should have_content(@category.name_title) }
    it { should have_content('Computer') }
    it { should_not have_content('Stuff') }
    it { should_not have_link(@category.name, href: edit_category_path(@category))}
  end

  describe "Show Categories - listings" do 
    let(:user) { FactoryGirl.create(:pixi_user, first_name: 'Jack', last_name: 'Snow', email: 'jack.snow@pixitest.com') }

    before(:each) do
      FactoryGirl.create :listing, seller_id: user.id
      user_login
      visit listings_path 
    end

    it { should have_link('Categories', href: categories_path) }

    it 'visits categories page', js: true do
      click_on 'Categories'
      page.should have_content 'Computer'
      page.should_not have_link(@category.name, href: edit_category_path(@category)) 
    end
  end

  describe 'Manage Categories - admin users' do
    let(:submit) { "Save Changes" }
    let(:user) { FactoryGirl.create :admin, confirmed_at: Time.now }

    before(:each) do
      user_login
      visit manage_categories_path 
    end

    it { should have_content('Categories') }
    it { should have_link('Active', href: manage_categories_path) }
    it { should have_link('Inactive', href: inactive_categories_path) }
    it { should have_link('New', href: new_category_path) }
    it { should have_content(@category.name_title) }
    it { should have_content('Computer') }
    it { should have_link(@category.name_title, href: edit_category_path(@category)) }

    describe 'visit inactive page', js: true do
      before do
        click_on 'Inactive'
      end

      it { should have_content('Stuff') }
    end

    describe 'visits edit page', js: true do
      before do
        click_on @category.name_title
      end

      it { should have_content("Category Name") }
      it { should have_content("Category Type") }
      it { should have_button("Save Changes") }

      it 'does not accept blank name' do
        expect { 
            fill_in 'category_name', with: ''
	    click_button submit }.not_to change(Category, :count)
        page.should have_content "blank" 
      end

      it 'changes status to inactive' do
        expect { 
          select('inactive', :from => 'category_status')
	  click_button submit }.not_to change(Category, :count)
        page.should_not have_content @category.name_title
      end

      it 'changes name' do
        expect { 
          fill_in 'category_name', with: 'Technology'
	  click_button submit }.not_to change(Category, :count)
        page.should have_content 'Technology'
      end

      describe 'create - invalid category', js: true do
        before do
          click_on 'New'
	end
        
        it { should have_button('Save Changes') }

        it 'does not accept blank name' do
          expect { 
	    click_button submit }.not_to change(Category, :count)

          page.should have_content "blank" 
        end
        
        it 'must have a picture' do
          expect { 
	    fill_in 'category_name', with: 'Boat'
	    click_button submit }.not_to change(Category, :count)

          page.should have_content "Must have a picture" 
        end
      end

      describe 'create - valid category', js: true do
        before do
          click_on 'New'
	end
        
        it { should have_button('Save Changes') }

        it 'accepts valid data' do
          expect { 
	    add_data_w_photo
	    fill_in 'category_name', with: 'Boat'
	    click_button submit; sleep 3
	    }.to change(Category, :count).by(1)

          page.should have_content "Boat"
        end
      end
    end
  end
end
