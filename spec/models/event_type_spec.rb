require 'spec_helper'
require 'rake'

describe EventType do
    before(:each) do
        @event_type = build(:event_type)
    end
    
    subject { @event_type }
    
    it { should respond_to(:description) }
    it { should respond_to(:status) }
    it { should respond_to(:code) }
    it { should respond_to(:hide) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:status) }
    it { should validate_presence_of(:code) }
    it { should validate_presence_of(:hide) }
    
    

    
    describe "load_event_types" do
        before do
            load File.expand_path("../../../lib/tasks/import_csv.rake", __FILE__)
            Rake::Task.define_task(:environment)
        end
        
        it "should call load_event_types" do
            Rake::Task["load_event_types"].invoke
        end
        
        #it { expect { Rake::Task['products:load'].invoke }.not_to raise_exception }
        
    end
        

    
    describe "active event_types" do
        before { create(:event_type) }
        it { EventType.active.should_not be_nil }
    end
    
    describe "inactive event_types" do
        before { create(:event_type, status: 'inactive') }
        it { EventType.active.should be_empty }
    end

end
