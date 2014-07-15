require 'spec_helper'
require 'rake'

describe 'load_conversations namespace rake task' do
  describe 'load_conversations:map_posts_to_conversations' do

    before do
      load File.expand_path("../../../lib/tasks/load_conversations.rake", __FILE__)
      Rake::Task.define_task(:environment)
    end

    it "should call map posts to conversations" do
      Post.should_receive :map_posts_to_conversations
      Rake::Task["load_conversations:map_posts_to_conversations"].invoke
    end
  end
end

