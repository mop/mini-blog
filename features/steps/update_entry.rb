
When "clicking unauthorized on edit entries" do
  @controller.body.should_not have_tag(
    'a',
    :href => "#{path_prefix}/entries/1/edit"
  )
  @controller = request("/entries/1/edit")
end

Then "he should be redirected to /entries" do
  @controller.should redirect_to("#{path_prefix}/entries")
end

When "clicking authorized on edit entries" do
  @controller.body.should have_tag(
    'a',
    :href => "#{path_prefix}/entries/1/edit"
  )
  @controller = request("/entries/1/edit")
end

When "filling out the form and submitting" do
  @controller = request('/entries/1', { :method => "PUT", :params => {
      :entry => { 
        :text => 'edited text', :title => 'edited'
      }
    }
  })
end

Then "the entry should be modified" do
  Entry.get(1).text.should eql('edited text')
  Entry.get(1).title.should eql('edited')
end
