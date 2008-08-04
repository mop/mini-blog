require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

describe Entries do
  include EntrySpecHelper
  include ResourceHelper

  it_should_be_resourceful(
    :auth_method => :logged_in?,
    :auth_actions => [
      :new, :create, :update, :edit, :destroy
    ]
  )
end

describe Entries, "index action" do
  before(:each) do
    @entries = []
  end

  def do_get
    dispatch_to(Entries, :index) do |controller|
      controller.stub!(:render)
    end
  end
  
  it 'should fetch all items from the database' do
    Entry.should_receive(:all_for_index).and_return(@entries)
    do_get
  end

  it 'should assign entries' do
    Entry.stub!(:all_for_index).and_return(@entries)
    do_get.assigns(:entries).should eql(@entries)
  end

  it 'should be successful' do
    Entry.stub!(:all_for_index).and_return(@entries)
    do_get.should be_successful
  end
end

describe Entries, 'show action with permalinks' do
  def do_get(params={})
    dispatch_to(
      Entries,
      :show, {
        :id        => '1',
        :permalink => 'title'
      }.merge(params)
    ) do |controller|

      controller.stub!(:render)
    end
  end
  
  it 'should fetch the item with the id' do
    Entry.should_receive(:get).with('1').and_return(:show)
    do_get
  end

  it 'should be successful' do
    Entry.stub!(:get).and_return(:show)
    do_get.should be_successful
  end

  it 'should even fetch the item if the permalink is wrong' do
    Entry.stub!(:get).and_return(:show)
    do_get(:permalink => 'something').should be_successful
  end

  it 'should have the correct route' do
    Entry.should_receive(:get).with('1').and_return(:show)
    get('/entries/1/title') do |controller|
      controller.stub!(:render)
    end.should be_successful
  end
end

describe Entries, 'archive' do
  def do_get
    dispatch_to(Entries, :archive) do |controller|
      if block_given?
        yield controller
      else
        controller.stub!(:render)
        controller.stub!(:logged_in?).and_return(false)
      end
    end
  end

  it 'should be successful' do
    Entry.stub!(:group_for_archive).and_return([])
    do_get.should be_successful
  end
  
  it 'should fetch the entries' do
    Entry.should_receive(:group_for_archive).and_return([])
    do_get
  end

  it 'should assign the entries the view' do
    Entry.stub!(:group_for_archive).and_return(:entry_groups)
    do_get.assigns(:entries).should eql(:entry_groups)
  end

  it 'should call render' do
    Entry.stub!(:group_for_archive).and_return([])
    do_get do |controller|
      controller.should_receive(:render)
    end
  end
end
