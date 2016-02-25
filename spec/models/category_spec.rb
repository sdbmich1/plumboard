require 'spec_helper'

describe Category do
  before(:each) do
    @category = FactoryGirl.build(:category)
  end

  subject { @category }

  it { should respond_to(:name) }
  it { should respond_to(:status) }
  it { should respond_to(:category_type_code) }
  it { should respond_to(:pixi_type) }
  it { should respond_to(:listings) }
  it { should respond_to(:temp_listings) }
  it { should respond_to(:active_listings) } 
  it { should respond_to(:pictures) }
  it { should have_many(:active_listings).class_name('Listing').conditions("status = 'active' AND end_date >= curdate()") }

  describe "when name is empty" do
    before { @category.name = "" }
    it { should_not be_valid }
  end

  describe "when name is entered" do
    before { @category.name = "gigs" }
    it { @category.name.should == "gigs" }
  end

  describe "when status is empty" do
    before { @category.status = "" }
    it { should_not be_valid }
  end

  describe "when status is entered" do
    before { @category.status = "active" }
    it { @category.status.should == "active" }
  end

  describe "when category_type_code is empty" do
    before { @category.category_type_code = "" }
    it { should_not be_valid }
  end

  describe "when category_type_code is entered" do
    before { @category.category_type_code = "gigs" }
    it { @category.category_type_code.should == "gigs" }
  end

  describe "active categories" do
    before { FactoryGirl.create(:category) }
    it { Category.active.should_not be_nil } 
    it { Category.inactive.should be_empty } 
  end

  describe "inactive categories" do
    before { FactoryGirl.create(:category, status: 'inactive') }
    it { Category.active.should be_empty } 
    it { Category.inactive.should_not be_empty } 
  end

  describe 'premium?' do
    it 'returns true' do
      @category.pixi_type = 'premium'
      @category.premium?.should be_true
    end

    it 'does not return true' do
      @category.pixi_type = nil
      @category.premium?.should_not be_true
    end
  end

  describe 'has_pixis?' do
    it 'returns true' do
      @cat = create :category
      create :listing, category_id: @cat.id
      @cat.has_pixis?.should be_true
    end

    it 'does not return true' do
      @category.has_pixis?.should_not be_true
    end
  end

  describe 'subcats?' do
    it 'returns true' do
      subcategory = @category.subcategories.build FactoryGirl.attributes_for(:subcategory)
      @category.subcats?.should be_true
    end

    it 'does not return true' do
      @category.subcats?.should_not be_true
    end
  end

  describe 'active_pixis_by_site' do
    before :each do
      picture = @category.pictures.build
      picture.photo = File.new Rails.root.join("spec", "fixtures", "photo.jpg")
      @category.save!
      @site = FactoryGirl.create(:site)
    end

    it 'does not return true' do
      @category.active_pixis_by_site(nil).should be_empty
    end

    it 'returns true' do
      @user = FactoryGirl.create(:pixi_user)
      FactoryGirl.create(:listing, seller_id: @user.id, category_id: @category.id, site_id: @site.id)
      @category.active_pixis_by_site(@site.id).should_not be_empty
    end
  end

  describe 'name_title' do
    it { @category.name_title.should == @category.name.titleize }

    it 'does not return titleized name' do
      @category.name = nil
      @category.name_title.should be_nil
    end
  end

  describe 'with_picture' do
    let(:category) { FactoryGirl.build :category }

    it "adds a picture" do
      category.with_picture.pictures.size.should == 1
    end
  end  

  describe 'pictures' do
    before(:each) do
      @sr = @category.pictures.build FactoryGirl.attributes_for(:picture)
    end

    it "has many pictures" do 
      @category.pictures.should include(@sr)
    end

    it "should destroy associated pictures" do
      @category.destroy
      [@sr].each do |s|
         Picture.find_by_id(s.id).should be_nil
       end
    end 
  end  

  describe "must have pictures" do
    it "does not save w/o at least one picture" do
      @category.should_not be_valid
    end

    it "saves with at least one picture" do
      picture = @category.pictures.build
      picture.photo = File.new Rails.root.join("spec", "fixtures", "photo.jpg")
      @category.save
      @category.should be_valid
    end
  end

  describe 'get_by_name' do
    it { expect(Category.get_by_name(@category.name)).to eq @category.id }
    it { expect(Category.get_by_name('')).to be_nil }
  end

  describe 'get_categories' do
    before :each, run: true do
      @user = create :contact_user
      @cat = FactoryGirl.create(:category, name: 'Test Type', category_type_code: 'sales')
      @listing = create :listing, seller_id: @user.id, category_id: @cat.id
    end
    it { expect(Category.get_categories(Listing.all)).to be_empty }
    it 'finds the categories', run: true do
      expect(Category.get_categories(Listing.all)).not_to be_empty
    end
    it 'finds the pixi w/ given category', run: true do
      @listing = create :listing, seller_id: @user.id
      expect(Category.get_categories(Listing.where(category_id: @cat.id)).count).to eq 1
    end
  end
end
