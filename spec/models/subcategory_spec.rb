require 'spec_helper'

describe Subcategory do
  before(:each) do
    @category = FactoryGirl.create(:category)
    @subcategory = @category.subcategories.build FactoryGirl.attributes_for(:subcategory)
  end

  subject { @subcategory }

  it { is_expected.to respond_to(:name) }
  it { is_expected.to respond_to(:status) }
  it { is_expected.to respond_to(:subcategory_type) }
  it { is_expected.to respond_to(:category) }
  it { is_expected.to respond_to(:pictures) }

  describe "when category_id is empty" do
    before { @subcategory.category_id = "" }
    it { is_expected.not_to be_valid }
  end

  describe "when name is empty" do
    before { @subcategory.name = "" }
    it { is_expected.not_to be_valid }
  end

  describe "when name is entered" do
    before { @subcategory.name = "gigs" }
    it { expect(@subcategory.name).to eq("gigs") }
  end

  describe "when status is empty" do
    before { @subcategory.status = "" }
    it { is_expected.not_to be_valid }
  end

  describe "when status is entered" do
    before { @subcategory.status = "active" }
    it { expect(@subcategory.status).to eq("active") }
  end

  describe "when subcategory_type is empty" do
    before { @subcategory.subcategory_type = "" }
    it { is_expected.not_to be_valid }
  end

  describe "when subcategory_type is entered" do
    before { @subcategory.subcategory_type = "gigs" }
    it { expect(@subcategory.subcategory_type).to eq("gigs") }
  end

  describe "active categories" do
    before { FactoryGirl.create(:subcategory) }
    it { expect(Subcategory.active).not_to be_nil } 
    it { expect(Subcategory.inactive).to be_empty } 
  end

  describe "inactive categories" do
    before { FactoryGirl.create(:subcategory, status: 'inactive') }
    it { expect(Subcategory.active).to be_empty } 
    it { expect(Subcategory.inactive).not_to be_empty } 
  end

  describe 'with_picture' do
    let(:subcategory) { FactoryGirl.build :subcategory }

    it "adds a picture" do
      expect(subcategory.with_picture.pictures.size).to eq(1)
    end
  end  

  describe 'pictures' do
    before(:each) do
      @sr = @subcategory.pictures.build FactoryGirl.attributes_for(:picture)
    end

    it "has many pictures" do 
      expect(@subcategory.pictures).to include(@sr)
    end

    it "should destroy associated pictures" do
      @subcategory.destroy
      [@sr].each do |s|
         expect(Picture.find_by_id(s.id)).to be_nil
       end
    end 
  end  

  describe "must have pictures" do

    it "does not save w/o at least one picture" do
      expect(@subcategory).not_to be_valid
    end

    it "saves with at least one picture" do
      picture = @subcategory.pictures.build
      picture.photo = File.new Rails.root.join("spec", "fixtures", "photo.jpg")
      @subcategory.save
      expect(@subcategory).to be_valid
    end
  end

end
