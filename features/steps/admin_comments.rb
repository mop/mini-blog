Given "a comment" do
  Comment.all.destroy!
  @comment = @entry.comments.create(
    :name       => 'commenter',
    :text       => 'a comment',
    :created_at => Time.now
  )
end

When "visiting /entries/1/comments/1/edit" do
  @controller = request("/entries/#{@entry.id}/comments/#{@comment.id}/edit")
end

Then "the access should be denied" do
  @controller.should redirect_to "#{path_prefix}/entries"
end

Given "clicking on the edit-link of a comment" do
  @controller.body.should have_tag(
    "a",
    :href => 
      "#{path_prefix}/entries/#{@entry.id}/comments/#{@comment.id}/edit"
  )
  @controller = request("/entries/#{@entry.id}/comments/#{@comment.id}/edit")
end

Then "the edit-form should be shown" do
  @controller.body.should have_tag(
    :form,
    :action => "#{path_prefix}/entries/#{@entry.id}/comments/#{@comment.id}"
  )
  [ 'name', 'url', 'mail' ].each do |name|
    @controller.body.should have_tag(
      :input, 
      :name => "comment[#{name}]"
    )
  end
  @controller.body.should have_tag(
    :textarea,
    :name => "comment[text]"
  )
end

When "submitting the comments form" do
  @controller = request("/entries/#{@entry.id}/comments/#{@comment.id}", {
    :method => "PUT", :params => {
      :comment => {
        :name => 'edited name',
        :text => 'edited text'
      }
    }
  })
end

Then 'the comment should have been changed' do
  @comment.reload
  @comment.name.should eql('edited name')
  @comment.text.should eql('edited text')
end

When "clicking on the destroy-link of a comment" do
  destroy_path = "/entries/#{@entry.id}/comments/#{@comment.id}/delete"
  @controller.body.should have_tag(
    :a,
    :href => 
      "#{path_prefix}/entries/#{@entry.id}/comments/#{@comment.id}",
    :class => 'delete'
  )
  @controller = request(
    "/entries/#{@entry.id}/comments/#{@comment.id}",
    :method => 'DELETE'
  )
end

Then "the comment should have been removed" do
  Comment.get(@comment.id).should be_nil
end
