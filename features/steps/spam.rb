Given /^a logged in user$/ do 
  Application.class_eval do 
    def authorize(name, pw)
      name == 'test' && pw == 'testpw'
    end
  end
  @controller = request('/sessions/', {
    :method => "POST", :params =>  { 
      'user'     => 'test',
      'password' => 'testpw' 
    }
  }) do |controller|
    controller.stub!(:session).and_return(session)
    controller.should_receive(:authorize).with('test', 'testpw').
        and_return(true)
  end
end

Given /^some spammy comments$/ do 
	Comment.auto_migrate!
  @comments = (1..4).map do |i|
    Comment.create(
      :entry_id   => @entry.id,
      :text       => "comment text #{i}",
      :name       => "commenter #{i}",
      :created_at => Time.now
    )
  end

  spam_state = { 
    1 => false,
    2 => true,
    3 => false,
    4 => true
  }.each do |id, state|
  	c = Comment.get(id)
    c.spam = state
    c.save
  end
end

Then /^only no\-spammy comments should be displayed$/ do 
	@controller.body.to_s.should_not match(/.*comment text 2.*/)
	@controller.body.to_s.should_not match(/.*comment text 4.*/)
end

Then /^all spammy comments should be displayed$/ do 
	@controller.body.to_s.should match(/.*comment text 2.*/)
	@controller.body.to_s.should match(/.*comment text 4.*/)
end

Then /^a form allowing to modify the spam\-status should be displayed$/ do 
  @controller.body.should have_tag(
    "input", :type => "checkbox", :name => "comment[spam]"
  )
end

When /^submitting the first comment form as no\-spam comment$/ do 
  comment = Comment.get(1)
  comment.spam.should == false
  @controller = request("/entries/#{@entry.id}/comments/#{comment.id}", {
    :method => "PUT", :params =>  { 
      :comment => { :id => comment.id, :spam => true }
    }
  })
end

Then /^the comments spam\-status should have been changed$/ do 
	Comment.all(:spam => false).size.should == 1
  Comment.get(1).spam.should == true
end
