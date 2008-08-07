steps_for(:site_creation_story) do
  shared_session_steps
  Given "a user" do
    Site.auto_migrate!
  end

  Given "visiting /sites" do
    @controller = do_get "/sites"
  end

  Given "pressing on /sites/new" do
    @controller.body.should have_tag(
      "a",
      :href => "#{path_prefix}/sites/new"
    )
    @controller = do_get '/sites/new'
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
    @controller = do_post('/sites', {
      'site' => {
        'title'      => 'created-title',
        'text'       => 'created-text',
        'created_at' => Time.now
    }})
  end

  Then "the site should be created" do
    Site.get(1).title.should eql('created-title')
    Site.get(1).text.should eql('created-text')
  end

  When "visiting /sites" do
    @controller = get "/sites"
  end

  Then "he should be redirected" do
    @controller.should redirect_to("#{path_prefix}/entries")
  end

  When "visiting authorized /sites" do
    @controller = do_get '/sites'
  end

  Then "the sites should be displayed" do
    @controller.body.should have_tag(
      "a",
      :href => "#{path_prefix}/sites/new"
    )
  end

  Given "a sample site" do
    Site.auto_migrate!
    Site.create({
      :title => 'sample-site',
      :text => 'sample-text',
      :created_at => Time.now
    })
  end

  Given "pressing on /sites/1/edit" do
    @controller.body.should have_tag(
      "a",
      :href => "#{path_prefix}/sites/1/edit"
    )
    @controller = do_get('/sites/1/edit')
  end

  When "submitting the edit-form" do
    @controller.body.should have_tag(
      "form",
      :action => "#{path_prefix}/sites/1"
    )
    @controller = do_put('/sites/1', {
      :site => { :title => 'edited-title', :text => 'edited-text' }
    })
  end

  Then "the site should be updated" do
    site = Site.get(1)
    site.title.should eql('edited-title')
    site.text.should eql('edited-text')
  end
end
