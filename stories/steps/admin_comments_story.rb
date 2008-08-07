steps_for(:admin_comments_story) do
  shared_session_steps
  shared_entry_steps

  Given "a user" do
    
  end

  Given "a comment" do
    Comment.all.destroy!
    @comment = @entry.comments.create(
      :name       => 'commenter',
      :text       => 'a comment',
      :created_at => Time.now
    )
  end

  When "visiting /entries/1/comments/1/edit" do
    @controller = do_get "/entries/#{@entry.id}/comments/#{@comment.id}/edit"
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
    @controller = do_get "/entries/#{@entry.id}/comments/#{@comment.id}/edit"
  end

  Then "the edit-form should be shown" do
    @controller.body.should have_tag(
      :form,
      :action => "#{path_prefix}#{url(:entry_comment, @comment)}"
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
  
  When "submitting the form" do
    @controller = do_put "/entries/#{@entry.id}/comments/#{@comment.id}", {
      :comment => {
        :name => 'edited name',
        :text => 'edited text'
      }
    }
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
        "#{path_prefix}#{url(:entry_comment, @comment)}",
      :class => 'delete'
    )
    @controller = do_delete url(:entry_comment, @comment)
  end

  Then "the comment should have been removed" do
    Comment.get(@comment.id).should be_nil
  end
end
