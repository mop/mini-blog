require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

describe Sites, "index action" do
  include SiteSpecHelper
  include ResourceHelper

  it_should_be_resourceful(
    :auth_method => :logged_in?,
    :auth_actions => [
      :new, :create, :update, :edit, :destroy, :index
    ]
  )
end

describe Sites, 'permalink navigation' do
  def do_get
    get '/sites/1/title-of-site' do |controller|
      controller.stub!(:render)
    end
  end

  it 'should be successful' do
    Site.stub!(:get).and_return(:show)
    do_get.should be_successful
  end

  it 'should call the correct get-method' do
    Site.should_receive(:get).with('1').and_return(:show)
    do_get.should be_successful
  end

  it 'should assign the the element to the correct variable' do
    Site.stub!(:get).and_return(:show)
    do_get.assigns(:site).should eql(:show)
  end
end
