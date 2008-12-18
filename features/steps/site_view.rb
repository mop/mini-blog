Given "a sample site" do
  Site.auto_migrate!
  Site.create({
    :title => 'title',
    :text => "### headline\n\ntest-text",
    :created_at => Time.now
  })
end

When "visiting /sites/1/title" do
  @controller = request("/sites/1/title")
end

Then "the site should be displayed" do
  @controller.body.to_s.should match(/title/)
  @controller.body.to_s.should match(/test-text/)
  @controller.body.should have_tag('h3')
end
