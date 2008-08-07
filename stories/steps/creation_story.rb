steps_for(:creation_story) do
  shared_session_steps
  shared_entry_steps

  Given("an user") do
    
  end
  
  Then("I should be redirected to /entries") do
    @controller.should redirect_to("#{path_prefix}/entries")
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
