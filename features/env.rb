# Sets up the Merb environment for Cucumber (thanks to krzys and roman)
require "rubygems"

# Add the local gems dir if found within the app root; any dependencies loaded
# hereafter will try to load from the local gems before loading system gems.
if (local_gem_dir = File.join(File.dirname(__FILE__), '..', 'gems')) && $BUNDLE.nil?
  $BUNDLE = true; Gem.clear_paths; Gem.path.unshift(local_gem_dir)
end

require "merb-core"
require "spec"
require "merb_cucumber/world/simple"
require "merb_cucumber/helpers/datamapper"

# Uncomment if you want transactional fixtures
# Merb::Test::World::Base.use_transactional_fixtures

Merb.start_environment(:testing => true, :adapter => 'runner', :environment => ENV['MERB_ENV'] || 'test')

require 'features/shared_steps/initializer.rb'
Dir['features/shared_steps/**/*.rb'].each do |shared_file|
  require shared_file unless shared_file.match(/initializer.rb$/)
end
  
Dir['features/matchers/**/*.rb'].each do |shared_file|
  require shared_file
end

Merb::Test::World::Simple.send(:include, CustomEntryMatchers)

Before do
  DataMapper.auto_migrate!
end
