def session
  @session ||= {}
end

def path_prefix
  Merb.config[:path_prefix]
end

steps_for(:creation_story) do
  Given("an user") do
    
  end
  
  When("going to /entries/new") do
    @controller = get("/entries/new")
  end
  
  Then("I should be redirected to /entries") do
    @controller.should redirect_to("#{path_prefix}/entries")
  end

  Given("going to /sessions/new") do
    @controller = get("/sessions/new")
  end
  
  Given("submitting the right credentials") do
    @controller.body.should have_tag(
      "input", :name => 'user', :type => 'text'
    )
    @controller.body.should have_tag(
      "input", :name => 'password', :type => 'password'
    )
    @controller = post('/sessions/', { 
      'user'     => 'test',
      'password' => 'testpw' 
    }) do |controller|
      controller.stub!(:session).and_return(session)
      controller.should_receive(:authorize).with('test', 'testpw').
          and_return(true)
    end
  end

  When("going to entries/new") do
    @controller = get('/entries/new') do |controller|
      controller.stub!(:session).and_return(session)
    end
  end

  Then("I should see the correct page") do
    @controller.body.should have_tag(
      'input',
      :type => 'text',
      :name => 'entry[title]'
    )
    @controller.body.should have_tag(
      'textarea',
      :name => 'entry[text]'
    )
  end

  Given("going to entries/new") do
    @controller = get('/entries/new') do |controller|
      controller.stub!(:session).and_return(session)
    end
  end

  When("submitting a new entry") do
    @controller = post("/entries/", { 
      :entry => {
        :text       => 'newtext',
        :title      => 'newtitle',
        :created_at => Time.now
    }}) do |controller|
      controller.stub!(:session).and_return(session)
    end
  end

  Then("I should see the new entry on the entries-page") do
    @controller = get("/entries/")
    @controller.body.should match(/newtext/)
    @controller.body.should match(/newtitle/)
  end
end
