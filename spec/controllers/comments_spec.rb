require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

def path_prefix
  Merb.config[:path_prefix]
end

describe Comments do

  include CommentSpecHelper
  include ResourceHelper

  it_should_be_resourceful(
    :auth_method  => :logged_in?,
    :auth_actions => [ :update, :edit, :destroy, :index, :show ],
    :nested_in    => :entries,
    :redirect_destroy_path => "#{path_prefix}/entries/1",
    :redirect_update_path  => "#{path_prefix}/entries/1",
    :redirect_create_path  => "#{path_prefix}/entries/1",
    :excludes => [:index, :show]
  )
end

describe Comments, 'javascript update' do
  include CommentSpecHelper

  before(:each) do
    @comment = merb_model_mock('comment', :update_attributes => true)
    Comment.stub!(:get).and_return(@comment)
  end

  def do_put
    dispatch_to(
      Comments,
      :update,
      :comment => valid_attributes, :format => 'js'
    ) do |con|

      con.stub!(:logged_in?).and_return(true)
      con.stub!(:render)
      con.stub!(:partial)
      yield con if block_given?
    end
  end

  it 'should render the partial' do
    do_put do |controller|
      controller.should_receive(:partial).with(
        '/entries/comment', :format => 'html', :with => @comment
      )
    end
  end

  it 'should receive the correct parameters' do
    @comment.should_receive(:update_attributes).with(hash_including(
      update_attributes
    )).and_return(true)
    do_put
  end

  it 'should render the partial even though update_attributes failed' do
    @comment.stub!(:update_attributes).and_return(false)
    do_put do |controller|
      controller.should_receive(:partial).with(
        '/entries/comment', :format => 'html', :with => @comment
      )
    end
  end

  it 'should assign the comment' do
    do_put.assigns(:comment)
  end
end
