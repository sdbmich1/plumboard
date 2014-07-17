require 'spec_helper'

feature "Categories" do
  let(:user) { FactoryGirl.create(:pixi_user) }
  let(:site) { FactoryGirl.create :site }
  subject { page }

  before(:each) do
    @category = FactoryGirl.create :category, name: 'Furniture', category_type: 'sales', status: 'active'
    FactoryGirl.create :category, name: 'Computer', category_type: 'sales', status: 'active'
    FactoryGirl.create :category, name: 'Stuff', category_type: 'sales', status: 'inactive'
  end

  def page_setup usr
    init_setup usr
    @listing = FactoryGirl.create :temp_listing, seller_id: @user.id, status: nil
    create :listing, category_id: @category.id, seller_id: @user.id
  end

  def add_data_w_photo
    attach_file('user_pic', Rails.root.join("spec", "fixtures", "photo.jpg"))
    sleep 2
  end

  describe "Show Categories" do 
    before do
      user = FactoryGirl.create :admin
      page_setup user
      visit manage_categories_path 
    end

    it 'shows content' do
      page.should have_content('Categories')
      page.should have_content(@category.name_title)
      page.should have_content('Computer')
      page.should_not have_content('Stuff')
      page.should have_link(@category.name, href: edit_category_path(@category))
    end
  end

  describe "Home Page w/ Login" do 
    before do
      user = FactoryGirl.create :pixi_user
      page_setup user
      visit categories_path 
    end

    it 'shows content' do
      page.should have_content('Home')
      page.should have_content(@category.name_title)
      page.should have_content('Computer')
      page.should_not have_content('Stuff')
      page.should_not have_link(@category.name, href: edit_category_path(@category))
    end
  end

  describe 'Manage Categories - admin users' do
    let(:submit) { "Save Changes" }

    before(:each) do
      user = FactoryGirl.create :admin
      page_setup user
      visit manage_categories_path 
    end

    it 'shows content' do
      page.should have_content('Categories')
      page.should have_link('Active', href: manage_categories_path)
      page.should have_link('Inactive', href: inactive_categories_path)
      page.should have_link('New', href: new_category_path)
      page.should have_content(@category.name_title)
      page.should have_content('Computer')
      page.should have_link(@category.name_title, href: edit_category_path(@category))
    end

    describe 'create - valid category' do
      before do
        click_on 'New'
      end
        
      it { should have_button('Save Changes') }

      it 'accepts valid data' do
        expect { 
	    add_data_w_photo
	    fill_in 'category_name', with: 'Boat'
            select('sales', :from => 'category_category_type')
	    click_button submit; sleep 3
	}.to change(Category, :count).by(1)

        page.should have_content "Boat"
      end
    end

      describe 'create - invalid category' do
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

    describe 'visit inactive page', js: true do
      before do
        click_on 'Inactive'
      end

      it { should have_content('Stuff') }
    end

    describe 'visits edit page' do
      before do
        click_on @category.name_title
      end

      it 'shows content' do
        page.should have_content("Category Name")
        page.should have_content("Category Type")
        page.should have_button("Save Changes")
      end

      it 'does not accept blank name' do
        expect { 
            fill_in 'category_name', with: ''
	    click_button submit }.not_to change(Category, :count)
        page.should_not have_content "Successfully" 
      end

      it 'changes status to inactive' do
        expect { 
          select('inactive', :from => 'category_status')
	  click_button submit }.not_to change(Category, :count)
        page.should_not have_content @category.name_title
      end

      it 'does not change status to inactive', js:true do
	expect(@category.has_pixis?).to be_true
	find('#category_status')['disabled'].should be_true
      end

      it 'changes name' do
        expect { 
          fill_in 'category_name', with: 'Technology'
	  click_button submit }.not_to change(Category, :count)
        page.should have_content 'Technology'
      end
    end
  end
end
