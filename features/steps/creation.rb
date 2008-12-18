Given("an user") do
  
end

Then("I should be redirected to /entries") do
  @controller.should redirect_to("#{path_prefix}/entries")
end

When("submitting a new entry") do
  @controller = request("/entries/", { 
    :method => 'POST', :params => {
      :entry => {
        :text       => 'newtext',
        :title      => 'newtitle',
        :created_at => Time.now
      }
    }
  })
end

Then("I should see the new entry on the entries-page") do
  @controller = request("/entries/")
  @controller.body.to_s.should match(/newtext/)
  @controller.body.to_s.should match(/newtitle/)
end
