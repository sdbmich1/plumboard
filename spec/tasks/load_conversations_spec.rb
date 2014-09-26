require 'spec_helper'
require 'rake'

describe 'load_conversations rake task' do
  describe 'map_posts_to_conversations' do

    before do
      load File.expand_path("../../../lib/tasks/load_conversations.rake", __FILE__)
      Rake::Task.define_task(:environment)
    end

    it "should call map posts to conversations" do
      Post.should_receive :map_posts_to_conversations
      Rake::Task["map_posts_to_conversations"].invoke
    end
  end
end

