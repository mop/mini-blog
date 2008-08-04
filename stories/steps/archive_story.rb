def path_prefix
  Merb.config[:path_prefix]
end

steps_for(:archive_story) do
  Given "a user" do
    
  end
  
  Given "a list of entries" do
    @entries = []
    Entry.all.destroy!
    2.times do |year|
      2.times do |month|
        @entries << Entry.create(
          :title => "entry in #{1 + month} #{2000 + year}",
          :text  => "shouldn't be displayed",
          :created_at => Time.gm(2000 + year, 1 + month)
        )
      end
    end
  end

  When "requesting /entries/archive" do
    @controller = get "/entries/archive"
  end
  
  Then "a list of all posts should be displayed" do
    @controller.body.should match(/entry in 1 2000/)
    @controller.body.should match(/entry in 2 2000/)
    @controller.body.should match(/entry in 2 2001/)
    @controller.body.should match(/entry in 1 2001/)
  end

  Then "a list of links should be displayed" do
    @controller.body.should have_tag(
      "a", 
      :href => 
        "#{path_prefix}/entries/#{@entries[0].id}/#{@entries[0].permalink}"
    )
    @controller.body.should have_tag(
      "a",
      :href => 
        "#{path_prefix}/entries/#{@entries[1].id}/#{@entries[1].permalink}"
    )
    @controller.body.should have_tag(
      "a", 
      :href => 
        "#{path_prefix}/entries/#{@entries[2].id}/#{@entries[2].permalink}"
    )
    @controller.body.should have_tag(
      "a", 
      :href => 
        "#{path_prefix}/entries/#{@entries[3].id}/#{@entries[3].permalink}"
    )
  end

  Then "no text should be displayed" do
    @controller.body.should_not match(/shouldn't be displayed/)
  end

  Given "the /entries/archive page" do
    @controller = get "/entries/archive"
  end

  When "clicking on an entry" do
    @controller.body.should have_tag(
      "a", 
      :href => 
        "#{path_prefix}/entries/#{@entries[0].id}/#{@entries[0].permalink}"
    )
    @controller = get("/entries/#{@entries[0].id}/#{@entries[0].permalink}")
  end

  Then "the entry page should be shown" do
    @controller.body.should match(/shouldn.*?t be displayed/)
  end
end
