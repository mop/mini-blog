steps_for(:comments_story) do
  Given "a user" do
    
  end

  Given "an entry" do
    Entry.all.destroy!
    @entry = Entry.create(
      :text       => 'text',
      :title      => 'title',
      :created_at => Time.now
    )
  end

  Given "some comments" do
    Comment.all.destroy!
    @comments = (1..4).map do |i|
      Comment.create(
        :entry_id   => @entry.id,
        :text       => "comment text #{i}",
        :name       => "commenter #{i}",
        :created_at => Time.now
      )
    end
  end

  When "visiting /entries/" do
    @controller = get '/entries'
  end

  Then "the count of the comments should be shown" do
    @controller.body.should match(/4/)
    @controller.body.should_not match(/comment text 1/)
  end

  When "visiting /entries/1" do
    @controller = get "/entries/#{@entry.id}" # small hack
  end

  Then "the comments should be shown" do
    (1..4).each do |i|
      @controller.body.should match(/commenter #{i}/)
      @controller.body.should match(/comment text #{i}/)
    end
  end

  Given "visiting /entries/1" do
    @controller = get "/entries/#{@entry.id}"
  end

  Given "a comments-form" do
    @controller.body.should have_tag(
      'form', :action => "#{path_prefix}/entries/#{@entry.id}/comments"
    )
    [ 'name', 'url', 'mail' ].each do |form_element|
      @controller.body.should have_tag(
        "input", :type => "text", :name => "comment[#{form_element}]"
      )
    end
  end

  When "submitting the form" do
    @controller = post "/entries/#{@entry.id}/comments", {
      :comment => {
        :text       => 'new comment',
        :name       => 'new commenter',
        :created_at => Time.now
      }
    }
  end

  Then "the user should be redirected" do
    @controller.should redirect
  end

  Then "the comment should be shown" do
    @controller = get "/entries/#{@entry.id}"
    @controller.body.should match(/new comment/)
    @controller.body.should match(/new commenter/)
  end

  When "submitting the form with malicious content" do
    @controller = post "/entries/#{@entry.id}/comments", {
      :comment => {
        :text       => '<html>evil</html>',
        :name       => '<script lang="something">evil script</script>',
        :created_at => Time.now
      }
    }
  end

  Then "the malicious content should be shown escaped" do
    @controller = get "/entries/#{@entry.id}"
    @controller.body.should_not match(/<html>evil<\/html>/)
    @controller.body.should_not match(
      /<script lang="something">evil script<\/script>/
    )
  end
end
