require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

describe Application, 'config loading' do
  def hash
    @hash ||= { 'user' => "hohoo", 'password' => "zomg" }
  end

  before(:each) do
    path = File.join(Merb.root, 'config', 'myconfig.yml')
    YAML.should_receive(:load_file).with(path).and_return(hash)
  end

  it 'should load the config correctly' do
    Application.allocate.send(:app_config).should eql(hash)
  end

  it 'should authorize correctly' do
    Application.allocate.send(:authorize, 'hohoo', 'zomg').should be_true
  end

  it 'should not authorize with the wrong credentials' do
    Application.allocate.send(:authorize, 'wrong', 'wrong').should be_false
  end
end
