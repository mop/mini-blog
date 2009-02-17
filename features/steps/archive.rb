def path_prefix
  Merb.config[:path_prefix]
end

def date_yielder
  2.times do |year|
    2.times do |month|
      yield [ (year + 2000), (month + 1) ]
    end
  end
end

Given "a user" do
  
end

Given "a list of entries" do
  @entries = []
  Entry.all.destroy!
  date_yielder do |year, month|
    @entries << Entry.create(
      :title      => "entry in #{month} #{year}",
      :text       => "shouldn't be displayed",
      :created_at => Time.gm(year, month)
    )
  end
end

When "requesting /entries/archive" do
  @controller = request("/entries/archive")
end

Then "a list of all posts should be displayed" do
  date_yielder do |year, month|
    @controller.body.to_s.should match(/entry in #{month} #{year}/)
  end
end

Then "a list of links should be displayed" do
  4.times do |i|
    @controller.body.should have_permalink(@entries[i])
  end
end

Then "no text should be displayed" do
  @controller.body.should_not match(/shouldn't be displayed/)
end

Given "the /entries/archive page" do
  @controller = request("/entries/archive")
end

When "clicking on an entry" do
  entry = @entries.first
  @controller.body.should have_permalink(entry)
  @controller = request("/entries/#{entry.id}/#{entry.permalink}")
end

Then "the entry page should be shown" do
  @controller.body.to_s.should match(/shouldn.*?t be displayed/)
end
