require 'spec_helper'

feature "Categories" do
  let(:user) { FactoryGirl.create(:pixi_user) }
  let(:site) { FactoryGirl.create :site }
  subject { page }

  before(:each) do
    @category_type = FactoryGirl.create(:category_type)
    @category = FactoryGirl.create :category, name: 'Furniture', category_type_code: @category_type, status: 'active'
    FactoryGirl.create :category, name: 'Computer', category_type_code: @category_type, status: 'active'
    FactoryGirl.create :category, name: 'Stuff', category_type_code: @category_type, status: 'inactive'
  end

  def page_setup usr
    init_setup usr
    @listing = FactoryGirl.create :temp_listing, seller_id: @user.id, status: nil
    create :listing, category_id: @category.id, seller_id: @user.id
  end

  def add_data_w_photo
    attach_file('usr_photo', Rails.root.join("spec", "fixtures", "photo.jpg"))
    sleep 2
  end

  describe "Show Categories" do 
    before do
      user = FactoryGirl.create :admin
      page_setup user
      visit manage_categories_path(status: 'active') 
    end

    it 'shows content' do
      expect(page).to have_content('Categories')
      expect(page).to have_content(@category.name_title)
      expect(page).to have_content('Computer')
      expect(page).not_to have_content('Stuff')
      expect(page).to have_link(@category.name, href: edit_category_path(@category))
    end
  end

  describe "Home Page w/ Login" do 
    before do
      user = FactoryGirl.create :pixi_user
      page_setup user
      visit categories_path 
    end

    it 'shows content' do
      expect(page).to have_content('Home')
      expect(page).to have_content(@category.name_title)
      expect(page).to have_content('Computer')
      expect(page).not_to have_content('Stuff')
      expect(page).not_to have_link(@category.name, href: edit_category_path(@category))
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
      expect(page).to have_content('Categories')
      expect(page).to have_link('Active', href: manage_categories_path(status: 'active'))
      expect(page).to have_link('Inactive', href: inactive_categories_path(status: 'inactive'))
      expect(page).to have_link('New', href: new_category_path(status: 'new'))
      expect(page).to have_content(@category.name_title)
      expect(page).to have_content('Computer')
      expect(page).to have_link(@category.name_title, href: edit_category_path(@category))
    end

    describe 'create - valid category' do
      before do
	visit new_category_path(status: 'new')
      end
        
      it { is_expected.to have_button('Save Changes') }

      it 'accepts valid data' do
        expect { 
	    add_data_w_photo
	    fill_in 'category_name', with: 'Boat'
            select('sales', :from => 'category_category_type_code')
	    click_button submit; sleep 3
	}.to change(Category, :count).by(1)

        expect(page).to have_content "Boat"
      end
    end

      describe 'create - invalid category' do
        before do
          click_on 'New'
	end
        
        it { is_expected.to have_button('Save Changes') }

        it 'does not accept blank name' do
          expect { 
	    click_button submit }.not_to change(Category, :count)

          expect(page).to have_content "blank" 
        end
        
        it 'must have a picture', js: true do
          expect {
            select('sales', :from => 'category_category_type_code')
            }.not_to change(Category, :count)
          expect { 
	    fill_in 'category_name', with: 'Boat'
	    click_button submit }.not_to change(Category, :count)
          expect(page).to have_content "Must have a picture"
        end
      end

    describe 'visit inactive page', js: true do
      before do
        click_on 'Inactive'
      end

      it { is_expected.to have_content('Stuff') }
    end

    describe 'visits edit page', js: true do
      before do
        click_on @category.name_title
      end

      it 'shows content' do
        expect(page).to have_button("Save Changes")
      end

      it 'does not accept blank name' do
        expect { 
            fill_in 'category_name', with: ''
	    click_button submit }.not_to change(Category, :count)
        expect(page).not_to have_content "Successfully" 
      end

      it 'changes status to inactive' do
        expect { 
          select('inactive', :from => 'category_status')
	  click_button submit }.not_to change(Category, :count)
        expect(page).not_to have_content @category.name_title
      end

      it 'does not change status to inactive', js:true do
	expect(@category.has_pixis?).to be_truthy
	expect(find('#category_status')['disabled']).to be_truthy
      end

      it 'changes name', js: true do
        expect { 
          fill_in 'category_name', with: 'Technology'
          select('sales', :from => 'category_category_type_code')
	  click_button submit }.not_to change(Category, :count)
        expect(page).to have_content 'Technology'
      end
    end
  end
end
