require File.join( File.dirname(__FILE__), "..", "spec_helper" )

def create(opts={})
  Entry.new({
    :title      => 'title',
    :text       => 'text',
    :created_at => Time.now
  }.merge(opts))
end

describe "A new entry" do
  include EntrySpecHelper
  include ValidationHelper
  include MarkdownHelper
  include PermalinkHelper

  it_should_assign_attributes
  it_should_validate_required
  it_should_cache_markdown(:text, :html_text)
  it_should_create_permalinks_on :title
  it_should_verify_uniqueness_of :title => 'test'
end

describe Entry, '#group_for_archive' do
  before(:each) do
    2.times do |year|
      2.times do |month|
        2.times do |day|
          entry = create(
            :created_at => Time.gm(2000 + year, 1 + month, 1 + day),
            :title => "newtitle #{year} #{month} #{day}"
          )
          entry.save
        end
      end
    end
    @entries = Entry.group_for_archive
  end

  after(:each) do
    Entry.all.destroy!
  end

  it 'should have a size of 4' do
    @entries.size.should eql(4)
  end

  it 'should have the date as first element' do
    date, entries = @entries[0]
    date.should eql(Time.gm(2001, 2))
  end

  it 'should have two entries as the second elements' do
    date, entries = @entries[0]
    entries.size.should eql(2)
  end

  it 'should have the correct order for the entries' do
    date, entries = @entries[0]
    entries[0].created_at.year.should eql(2001)
    entries[0].created_at.month.should eql(2)
    entries[0].created_at.day.should eql(2)
  end
end

describe Entry, '#all_for_index' do
  before(:each) do
    20.times do |i|
      create(
        :created_at => Time.gm(2000 + i),
        :title      => "title #{i}"
      ).save
    end
  end

  after(:each) do
    Entry.all.destroy!
  end

  it 'should only return 10 items' do
    Entry.all_for_index.size.should eql(10)
  end

  it 'should return the 10 most recent items' do
    Entry.all_for_index[0].created_at.year.should eql(2019)
    Entry.all_for_index[9].created_at.year.should eql(2010)
  end
end
