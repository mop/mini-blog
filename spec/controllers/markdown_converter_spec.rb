require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

describe MarkdownConverter, 'unauthorized index action' do
  def do_get(markdown="## headline", &block)
    dispatch_to(MarkdownConverter, :index, :markdown => markdown, &block)
  end

  it 'should not return the markdown' do
    do_get.body.should_not match(/h2/)
  end
end

describe MarkdownConverter, "authorized index action" do
  def do_get(markdown="## headline")
    dispatch_to(
      MarkdownConverter,
      :index,
      :markdown => markdown
    ) do |controller|

      controller.stub!(:logged_in?).and_return(true)
      yield controller if block_given?
    end
  end

  shared_examples_for 'all preview pages' do
    it 'should be successful' do
      do_get.should be_successful
    end

    it 'should return the markdown' do
      do_get.body.should match(/h2/)
    end

    it 'should not render the layout' do
      do_get.body.should_not match(/html/)
    end
  end

  it 'should convert code via ultraviolet' do
    str = "<filter:code lang='ruby'>puts 'hello world'</filter:code>"
    do_get(str).body.should_not match(/filter/)
  end
end

describe MarkdownConverter, 'preview action' do
  def do_get(markdown="## headline")
    dispatch_to(
      MarkdownConverter,
      :preview,
      :markdown => markdown
    ) do |controller|

      controller.stub!(:logged_in?).and_return(false)
      yield controller if block_given?
    end
  end

  it_should_behave_like 'all preview pages' 

  it 'should not convert code via ultraviolet' do
    str = "<filter:code lang='ruby'>puts 'hello world'</filter:code>"
    do_get(str).body.should match(/filter/)
  end
end

