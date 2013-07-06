require 'spec_helper'

describe Subcategory do
  before(:each) do
    @category = FactoryGirl.create(:category)
    @subcategory = @category.subcategories.build FactoryGirl.attributes_for(:subcategory)
  end

  subject { @subcategory }

  it { should respond_to(:name) }
  it { should respond_to(:status) }
  it { should respond_to(:subcategory_type) }
  it { should respond_to(:category) }
  it { should respond_to(:pictures) }

  describe "when category_id is empty" do
    before { @subcategory.category_id = "" }
    it { should_not be_valid }
  end

  describe "when name is empty" do
    before { @subcategory.name = "" }
    it { should_not be_valid }
  end

  describe "when name is entered" do
    before { @subcategory.name = "gigs" }
    it { @subcategory.name.should == "gigs" }
  end

  describe "when status is empty" do
    before { @subcategory.status = "" }
    it { should_not be_valid }
  end

  describe "when status is entered" do
    before { @subcategory.status = "active" }
    it { @subcategory.status.should == "active" }
  end

  describe "when subcategory_type is empty" do
    before { @subcategory.subcategory_type = "" }
    it { should_not be_valid }
  end

  describe "when subcategory_type is entered" do
    before { @subcategory.subcategory_type = "gigs" }
    it { @subcategory.subcategory_type.should == "gigs" }
  end

  describe "active categories" do
    before { FactoryGirl.create(:subcategory) }
    it { Subcategory.active.should_not be_nil } 
    it { Subcategory.inactive.should be_empty } 
  end

  describe "inactive categories" do
    before { FactoryGirl.create(:subcategory, status: 'inactive') }
    it { Subcategory.active.should be_empty } 
    it { Subcategory.inactive.should_not be_empty } 
  end

  describe 'with_picture' do
    let(:subcategory) { FactoryGirl.build :subcategory }

    it "adds a picture" do
      subcategory.with_picture.pictures.size.should == 1
    end
  end  

  describe 'pictures' do
    before(:each) do
      @sr = @subcategory.pictures.build FactoryGirl.attributes_for(:picture)
    end

    it "has many pictures" do 
      @subcategory.pictures.should include(@sr)
    end

    it "should destroy associated pictures" do
      @subcategory.destroy
      [@sr].each do |s|
         Picture.find_by_id(s.id).should be_nil
       end
    end 
  end  

  describe "must have pictures" do

    it "does not save w/o at least one picture" do
      @subcategory.should_not be_valid
    end

    it "saves with at least one picture" do
      picture = @subcategory.pictures.build
      picture.photo = File.new Rails.root.join("spec", "fixtures", "photo.jpg")
      @subcategory.save
      @subcategory.should be_valid
    end
  end

end
