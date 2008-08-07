module EntryStoryHelper
  module EntryStoryGroupMethods
    def shared_entry_steps
      Given "a entry" do
        Entry.auto_migrate!
        @entry = Entry.create(
          :title      => 'title',
          :text       => 'text',
          :created_at => Time.now
        )
      end

      Given "visiting /entries/1" do
        @controller = do_get "/entries/#{@entry.id}"
      end

      Given "visiting /entries/new" do
        @controller = do_get "/entries/new"
      end

      When "visiting /entries/new" do
        @controller = do_get "/entries/new"
      end

      Given "visiting /entries/1/title" do
        @controller = do_get "/entries/#{@entry.id}/title"
        @controller.body.should match(/title/)
        @controller.body.should match(/text/)
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
    end
  end

  module EntryStoryMethods
  end
end

include_shared_steps(EntryStoryHelper)
