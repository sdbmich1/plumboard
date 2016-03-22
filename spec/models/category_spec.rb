require 'spec_helper'

describe Category do
  before(:each) do
    @category = FactoryGirl.build(:category)
  end

  subject { @category }

  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:status) }
  it { is_expected.to respond_to(:category_type_code) }
  it { is_expected.to respond_to(:pixi_type) }
  it { is_expected.to respond_to(:listings) }
  it { is_expected.to respond_to(:temp_listings) }
  it { is_expected.to respond_to(:active_listings) } 
  it { is_expected.to respond_to(:pictures) }
  it { is_expected.to have_many(:active_listings).class_name('Listing').conditions("status = 'active' AND end_date >= curdate()") }

  describe "when name is empty" do
    before { @category.name = "" }
    it { is_expected.not_to be_valid }
  end

  describe "when name is entered" do
    before { @category.name = "gigs" }
    it { expect(@category.name).to eq("gigs") }
  end

  describe "when status is empty" do
    before { @category.status = "" }
    it { is_expected.not_to be_valid }
  end

  describe "when status is entered" do
    before { @category.status = "active" }
    it { expect(@category.status).to eq("active") }
  end

  describe "when category_type_code is empty" do
    before { @category.category_type_code = "" }
    it { is_expected.not_to be_valid }
  end

  describe "when category_type_code is entered" do
    before { @category.category_type_code = "gigs" }
    it { expect(@category.category_type_code).to eq("gigs") }
  end

  describe "active categories" do
    before { FactoryGirl.create(:category) }
    it { expect(Category.active).not_to be_nil } 
    it { expect(Category.inactive).to be_empty } 
  end

  describe "inactive categories" do
    before { FactoryGirl.create(:category, status: 'inactive') }
    it { expect(Category.active).to be_empty } 
    it { expect(Category.inactive).not_to be_empty } 
  end

  describe 'premium?' do
    it 'returns true' do
      @category.pixi_type = 'premium'
      expect(@category.premium?).to be_truthy
    end

    it 'does not return true' do
      @category.pixi_type = nil
      expect(@category.premium?).not_to be_truthy
    end
  end

  describe 'has_pixis?' do
    it 'returns true' do
      @cat = create :category
      create :listing, category_id: @cat.id
      expect(@cat.has_pixis?).to be_truthy
    end

    it 'does not return true' do
      expect(@category.has_pixis?).not_to be_truthy
    end
  end

  describe 'subcats?' do
    it 'returns true' do
      subcategory = @category.subcategories.build FactoryGirl.attributes_for(:subcategory)
      expect(@category.subcats?).to be_truthy
    end

    it 'does not return true' do
      expect(@category.subcats?).not_to be_truthy
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
      expect(@category.active_pixis_by_site(nil)).to be_empty
    end

    it 'returns true' do
      @user = FactoryGirl.create(:pixi_user)
      FactoryGirl.create(:listing, seller_id: @user.id, category_id: @category.id, site_id: @site.id)
      expect(@category.active_pixis_by_site(@site.id)).not_to be_empty
    end
  end

  describe 'name_title' do
    it { expect(@category.name_title).to eq(@category.name.titleize) }

    it 'does not return titleized name' do
      @category.name = nil
      expect(@category.name_title).to be_nil
    end
  end

  describe 'with_picture' do
    let(:category) { FactoryGirl.build :category }

    it "adds a picture" do
      expect(category.with_picture.pictures.size).to eq(1)
    end
  end  

  describe 'pictures' do
    before(:each) do
      @sr = @category.pictures.build FactoryGirl.attributes_for(:picture)
    end

    it "has many pictures" do 
      expect(@category.pictures).to include(@sr)
    end

    it "should destroy associated pictures" do
      @category.destroy
      [@sr].each do |s|
         expect(Picture.find_by_id(s.id)).to be_nil
       end
    end 
  end  

  describe "must have pictures" do
    it "does not save w/o at least one picture" do
      expect(@category).not_to be_valid
    end

    it "saves with at least one picture" do
      picture = @category.pictures.build
      picture.photo = File.new Rails.root.join("spec", "fixtures", "photo.jpg")
      @category.save
      expect(@category).to be_valid
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
