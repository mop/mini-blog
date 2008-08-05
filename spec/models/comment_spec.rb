require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Comment do
  include CommentSpecHelper
  include ValidationHelper
  include MarkdownHelper
  
  it_should_assign_attributes
  it_should_validate_required
  it_should_belong_to :entry
  it_should_cache_markdown(:text, :html_text, :filter_code => false)
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
