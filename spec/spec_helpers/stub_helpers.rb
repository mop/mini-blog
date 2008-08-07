dir = File.dirname(__FILE__)
Dir["#{dir}/stub_helpers/**/*.rb"].each do |file|
  require file
end
