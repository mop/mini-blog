def path_prefix
  Merb.config[:path_prefix]
end

def session
  @session ||= {}
end

def do_get(path)
  get path do |controller|
    controller.stub!(:session).and_return(session)
  end
end

def do_put(path, params={})
  put(path, params) do |controller|
    controller.stub!(:session).and_return(session)
  end
end

steps_for(:update_entry_story) do
  Given "an user" do
    
  end
  
  Given "a sample entry" do
    Entry.auto_migrate!
    Entry.create({
      :title      => 'title',
      :text       => 'text',
      :created_at => Time.now
    })
  end

  Given "visiting unauthorized /entries/1/title" do
    @controller = get "/entries/1/title"
    @controller.body.should match(/title/)
    @controller.body.should match(/text/)
  end

  When "clicking unauthorized on edit entries" do
    @controller.body.should_not have_tag(
      'a',
      :href => "#{path_prefix}/entries/1/edit"
    )
    @controller = get "/entries/1/edit"
  end

  Then "he should be redirected to /entries" do
    @controller.should redirect_to("#{path_prefix}/entries")
  end

  Given "visiting /sessions/new" do
    @controller = get "/sessions/new"
  end

  Given "filling in the correct credentials" do
    @controller.body.should have_tag(
      "input", :name => 'user', :type => 'text'
    )
    @controller.body.should have_tag(
      "input", :name => 'password', :type => 'password'
    )
  end

  Given "submitting the form" do
    @controller = post('/sessions/', { 
      'user'     => 'test',
      'password' => 'testpw' 
    }) do |controller|
      controller.stub!(:session).and_return(session)
      controller.should_receive(:authorize).with('test', 'testpw').
          and_return(true)
    end
  end

  Given "visiting authorized /entries/1/title" do
    @controller = do_get('/entries/1/title')
  end

  When "clicking authorized on edit entries" do
    @controller.body.should have_tag(
      'a',
      :href => "#{path_prefix}/entries/1/edit"
    )
    @controller = do_get "/entries/1/edit"
  end

  Then "the edit form should be displayed" do
    @controller.body.should have_tag(
      "form",
      :action => "#{path_prefix}/entries/1"
    )
    @controller.body.should have_tag(
      "input", :type => 'text', :name => 'entry[title]'
    )
    @controller.body.should have_tag(
      "textarea", :name => 'entry[text]'
    )
  end

  Given "clicking authorized on edit entries" do
    @controller.body.should have_tag(
      'a',
      :href => "#{path_prefix}/entries/1/edit"
    )
    @controller = do_get "/entries/1/edit"
  end

  When "filling out the form and submitting" do
    @controller.body.should have_tag(
      "form",
      :action => "#{path_prefix}/entries/1"
    )
    @controller.body.should have_tag(
      "input", :type => 'text', :name => 'entry[title]'
    )
    @controller.body.should have_tag(
      "textarea", :name => 'entry[text]'
    )
    @controller = do_put('/entries/1', { :entry => { 
      :text => 'edited text', :title => 'edited'
    } })
  end

  Then "the entry should be modified" do
    Entry.get(1).text.should eql('edited text')
    Entry.get(1).title.should eql('edited')
  end
end
