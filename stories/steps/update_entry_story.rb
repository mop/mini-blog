steps_for(:update_entry_story) do
  shared_session_steps
  shared_entry_steps
  Given "an user" do
    
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

  When "clicking authorized on edit entries" do
    @controller.body.should have_tag(
      'a',
      :href => "#{path_prefix}/entries/1/edit"
    )
    @controller = do_get "/entries/1/edit"
  end

  Given "clicking authorized on edit entries" do
    @controller.body.should have_tag(
      'a',
      :href => "#{path_prefix}/entries/1/edit"
    )
    @controller = do_get "/entries/1/edit"
  end

  When "filling out the form and submitting" do
    @controller = do_put('/entries/1', { :entry => { 
      :text => 'edited text', :title => 'edited'
    } })
  end

  Then "the entry should be modified" do
    Entry.get(1).text.should eql('edited text')
    Entry.get(1).title.should eql('edited')
  end
end
