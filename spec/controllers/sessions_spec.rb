require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

describe Sessions, "new action" do
  def do_get
    dispatch_to(Sessions, :new) do |controller|
      controller.stub!(:render)
    end
  end

  it 'should render the login form' do
    do_get.should be_successful
  end
end

describe Sessions, "unsuccessful creation" do
  def do_post
    params = { :user => 'test', :password => 'testpw' }
    dispatch_to(Sessions, :create, params) do |controller|
      controller.stub!(:render)
      controller.stub!(:authorize).and_return(false)
      yield controller if block_given?
    end
  end

  def session_hash
    @session_hash ||= {}
  end

  it 'should redirect to entries' do
    do_post.should redirect_to("#{Merb.config[:path_prefix]}/entries") do
      controller.stub!(:session).and_return(session_hash)
    end
    session_hash[:logged_in].should be_nil
  end
end

describe Sessions, 'authorized create' do
  def do_post
    params = { :user => 'test', :password => 'testpw' }
    dispatch_to(Sessions, :create, params) do |controller|
      controller.stub!(:render)
      controller.stub!(:authorize).and_return(true)
      yield controller if block_given?
    end
  end

  def session_hash
    @session_hash ||= {}
  end

  it 'should redirect to the entries' do
    do_post.should redirect_to("#{Merb.config[:path_prefix]}/entries")
  end

  it 'should set the logged_in-flag in the session' do
    do_post do |controller|
      controller.stub!(:session).and_return(session_hash)
    end
    session_hash[:logged_in].should be_true
  end

  it 'should send the credentials to the authorize-method' do
    do_post do |controller|
      controller.should_receive(:authorize).with('test', 'testpw').
        and_return(true)
    end
  end
end

describe Sessions, 'destroy' do
  def session_hash
    @session_hash ||= {}
  end

  def do_post
    session_hash[:logged_in] = true
    dispatch_to(Sessions, :destroy) do |controller|
      controller.stub!(:render)
      yield controller if block_given?
    end
  end

  it 'should clear the logged_in flag' do
    do_post do |controller|
      controller.stub!(:session).and_return(session_hash)
    end
    session_hash[:logged_in].should be_nil
  end

  it 'should redirect to the entries' do
    do_post.should redirect_to("#{Merb.config[:path_prefix]}/entries")
  end
end
