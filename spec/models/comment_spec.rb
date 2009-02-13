require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Comment do
  include CommentSpecHelper
  include ValidationHelper
  include MarkdownHelper
  
  it_should_assign_attributes
  it_should_validate_required_for(:name, :text)
  it_should_belong_to :entry
  it_should_cache_markdown(:text, :html_text, :filter_code => false)
end

describe Comment, 'created_at field' do
  include CommentSpecHelper
  before(:each) do
    @comment = Comment.new(valid_attributes)
    @comment.created_at = nil
  end

  it 'should fill the created_at column after save' do
    @comment.save
    @comment.created_at.should_not be_nil
  end

  it 'should not update the created_at column on update' do
    @comment.save
    cached = @comment.created_at
    @comment.save
    cached.should eql(@comment.created_at)
  end
end

describe Comment, 'xss filtering' do
  include CommentSpecHelper

  before(:each) do
    @comment = Comment.new(valid_attributes)
    @comment.text = 
      "\n## markdown \n" +
      '<html>some texttext text' +
      '<script lang="javascript" /> ' + 
      'text text text </html>'
  end

  after(:each) do
    @comment.destroy unless @comment.new_record?
  end

  it 'should not allow html-tags in comments' do
    @comment.save
    @comment.html_text.should_not match(/<html>/)
  end
  
  it 'should not allow <script tags in comments' do
    @comment.save
    @comment.html_text.should_not match(/<script/)
  end
end

describe Comment, 'spam filtering' do
  include CommentSpecHelper

  it "should try to detect spam on creation" do
    spam_stub.should_receive(:spam?).with("textmessage")
    SpamHelper.stub!(:new).and_return(spam_stub)

    comment = Comment.new(valid_attributes.merge(:text => "textmessage"))
    comment.save
  end

  it "should set the spam flag, when spam is reported" do
    spam_stub.stub!(:spam?).and_return(true)
    SpamHelper.stub!(:new).and_return(spam_stub)

    comment = Comment.new(valid_attributes)
    comment.save
    comment.spam.should be_true
  end

  it "should not the spam flag, when no spam is reported" do
    spam_stub.stub!(:spam?).and_return(false)
    SpamHelper.stub!(:new).and_return(spam_stub)

    comment = Comment.new(valid_attributes)
    comment.save
    comment.spam.should be_false
  end

  def spam_stub
  	@spam_stub ||= stub("spam_stub")
  end
end
