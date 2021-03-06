require 'cucumber/rake/task'

cucumber_options = proc do |t|
  #t.binary        = Merb.root / 'bin' / 'cucumber'
  t.cucumber_opts = "--format pretty --require features/env.rb"
end

Cucumber::Rake::Task.new(:features, &cucumber_options)
Cucumber::Rake::FeatureTask.new(:feature, &cucumber_options)
namespace :merb_cucumber do 
  task :test_env do
    Merb.start_environment(:environment => "test", :adapter => 'runner')
  end
end


dependencies = ['merb_cucumber:test_env', 'db:automigrate', 'spam:clear']
task :features => dependencies
task :feature  => dependencies

