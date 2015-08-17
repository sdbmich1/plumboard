require 'spec_helper'

# Checks if CSV import successfully loaded into database
# task -- name of the rake task being tested
# params -- parameters for the rake task
# model -- class of objects loaded from CSV file
# attrs -- key: attribute of the model
#          value: value to look for in database. You can pass an array of values if you want to look up more than one.
shared_examples "import_csv" do |task, params, model, attrs|
  it 'should load into database' do
    Rake::Task[task].execute params
    attrs.each { |key, values| Array.wrap(values).each { |value| model.exists?(key => value).should be_true } }
  end
end

# Verifies that a particular method is being called by the task
# model -- model receiving method call
# method -- method being called in rake task
shared_examples "manage_server" do |task, params, model, method|
  it "should receive method call" do
    model.should_receive method
    Rake::Task[task].execute params
  end
end
