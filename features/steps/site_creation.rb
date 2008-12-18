Given "visiting /sites" do
  @controller = request("/sites")
end

Given "pressing on /sites/new" do
  @controller.body.should have_tag(
    "a",
    :href => "#{path_prefix}/sites/new"
  )
  @controller = request('/sites/new')
end

Given "filling in all elements" do
  @controller.body.should have_tag(
    "input", :type => "text", :name => "site[title]"
  )
  @controller.body.should have_tag(
    "textarea", :name => "site[text]"
  )
end

When "submitting the creation-form" do
  @controller.body.should have_tag(
    'form', :action => "#{path_prefix}/sites"
  )
  @controller = request('/sites', {
    :method => "POST", :params => {
      'site' => {
        'title'      => 'created-title',
        'text'       => 'created-text',
        'created_at' => Time.now
      }
    }
  })
end

Then "the site should be created" do
  Site.get(1).title.should eql('created-title')
  Site.get(1).text.should eql('created-text')
end

Then "he should be redirected" do
  @controller.should redirect_to("#{path_prefix}/entries")
end

When "visiting authorized /sites" do
  @controller = request('/sites')
end

Then "the sites should be displayed" do
  @controller.body.should have_tag(
    "a",
    :href => "#{path_prefix}/sites/new"
  )
end

Given "an existing sample site" do
  Site.auto_migrate!
  Site.create({
    :title      => 'sample-site',
    :text       => 'sample-text',
    :created_at => Time.now
  })
end

Given "pressing on /sites/1/edit" do
  @controller.body.should have_tag(
    "a",
    :href => "#{path_prefix}/sites/1/edit"
  )
  @controller = request('/sites/1/edit')
end

When "submitting the edit-form" do
  @controller.body.should have_tag(
    "form",
    :action => "#{path_prefix}/sites/1"
  )
  @controller = request('/sites/1', {
    :method => "PUT", :params => {
      :site => { :title => 'edited-title', :text => 'edited-text' }
    }
  })
end

Then "the site should be updated" do
  site = Site.get(1)
  site.title.should eql('edited-title')
  site.text.should eql('edited-text')
end
