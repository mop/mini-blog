steps_for(:entries_story) do
  Given("5 entries") do
    Entry.all.destroy!
    @entries = []
    5.times do |i|
      @entries << Entry.create({
        :text       => "text #{i}",
        :title      => "title #{i}",
        :created_at => Time.now
      })
    end
  end

  When(/I request \/(entries|entries.rss2)/) do |url|
    @controller = get("/#{url}")
  end

  Given("requesting /entries") do
    @controller = get('/entries')
  end

  Then("I will see the 5 entries") do
    5.times do |i|
      @controller.body.should match(/text #{i}/)
      @controller.body.should match(/title #{i}/)
    end
  end

  When("I click on the headline") do
    entry = @entries[0]
    @controller.body.should have_selector("h2 a#entry_#{entry.id}")
    @controller.body.should have_permalink(entry)
    @controller = get(url(:permalink_entry, entry))
  end

  Then("I will see the selected entry") do
    @controller.body.should have_permalink(@entries[0])
    @controller.body.should match(/text 0/)
    @controller.body.should match(/title 0/)
  end

  Then("I will see the 5 entries in rss2") do
    @controller.body.should have_tag("rss")
    @controller.body.should match(/text 0/)
    @controller.body.should match(/title 0/)
  end
end
