describe SpamHelper do
  before(:each) do
    Merb::Config[:bayes_file] = 'bayes.dat'
  end

  it "should load the config file on creation" do
    file_stub.should_receive(:read).with('bayes.dat').and_return(:content)

    SpamHelper.new(file_stub)
  end

  it "should initialize the naive bayes filter correctly" do
    stub_file!

    Bayes.should_receive(:new).with(:content)
    SpamHelper.new(file_stub)
  end

  it "should use the naive bayes classifier correctly for spam detection" do
    stub_file!

    Bayes.stub!(:new).and_return(bayes_stub)
    bayes_stub.should_receive(:classify).with(:text)

    SpamHelper.new(file_stub).spam?(:text)
  end

  def stub_file!
    file_stub.stub!(:read).and_return(:content)
  end

  def bayes_stub
  	@bayes_stub ||= stub("bayes")
  end

  def file_stub
  	@file_stub ||= stub("file_stub")
  end
end
