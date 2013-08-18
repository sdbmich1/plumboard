require 'spec_helper'

describe Category do
  before(:each) do
    @category = FactoryGirl.build(:category)
  end

  subject { @category }

  it { should respond_to(:name) }
  it { should respond_to(:status) }
  it { should respond_to(:category_type) }
  it { should respond_to(:pixi_type) }
  it { should respond_to(:listings) }
  it { should respond_to(:temp_listings) }
  it { should respond_to(:active_listings) } 
  it { should respond_to(:pictures) }

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

  describe "when category_type is empty" do
    before { @category.category_type = "" }
    it { should_not be_valid }
  end

  describe "when category_type is entered" do
    before { @category.category_type = "gigs" }
    it { @category.category_type.should == "gigs" }
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
    end

    it 'returns true' do
      @user = FactoryGirl.create(:pixi_user)
      @site = FactoryGirl.create(:site)
      FactoryGirl.create(:listing, seller_id: @user.id, category_id: @category.id, site_id: @site.id)
      @category.active_pixis_by_site(@site.id).should_not be_empty
    end

    it 'does not return true' do
      @category.active_pixis_by_site(nil).should be_empty
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

end
