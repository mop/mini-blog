Given "a entry" do
  Entry.auto_migrate!
  @entry = Entry.create(
    :title      => 'title',
    :text       => 'text',
    :created_at => Time.now
  )
end

Given "visiting /entries/new" do
  @controller = request("/entries/new")
end

Given "visiting /entries/1/title" do
  @controller = request("/entries/#{@entry.id}/title")
  @controller.body.to_s.should match(/title/)
  @controller.body.to_s.should match(/text/)
end

Then "the entry form should be displayed for $type" do |type|
  action = type == "creation" ? "/entries" : "/entries/#{@entry.id}"
  @controller.body.should have_tag(
    "form",
    :action => "#{path_prefix}#{action}"
  )
  @controller.body.should have_tag(
    "input", :type => 'text', :name => 'entry[title]'
  )
  @controller.body.should have_tag(
    "textarea", :name => 'entry[text]'
  )
end
