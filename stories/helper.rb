require 'rubygems'
require 'spec/rake/spectask'
require File.join(File.dirname(__FILE__), "..", "spec", "spec_helper")
require 'spec/mocks'
require 'spec/story'

require 'merb_stories'

require 'stories/shared_steps/initializer.rb'
Dir['stories/shared_steps/**/*.rb'].each do |shared_file|
  require shared_file unless shared_file.match(/initializer.rb$/)
end
Dir['stories/matchers/**/*.rb'].each do |shared_file|
  require shared_file
end

Spec::Story::World.send(:include, CustomEntryMatchers)

class MerbStory
  # Include your custom helpers here
  include Merb::Test::RequestHelper
  include Merb::Test::ViewHelper
  include Merb::Test::RouteHelper
  include Merb::Test::Helpers
end

Dir['stories/steps/**/*.rb'].each do |steps_file|
  require steps_file
end
