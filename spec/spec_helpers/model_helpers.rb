dir = File.dirname(__FILE__)
Dir["#{dir}/model_helpers/**/*.rb"].each do |file|
  require file
end
