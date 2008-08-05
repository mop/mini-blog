require 'dm-validations'
require 'markdown_filter'
require 'permalink_creator'

class Entry
  include DataMapper::Resource
  include PermalinkCreator
  include MarkdownFilter

  property :id,            Integer,  :serial   => true
  property :title,         String,   :nullable => false
  property :text,          Text,     :nullable => false
  property :html_text,     Text
  property :created_at,    DateTime, :nullable => false
  property :permalink,     String

  has n, :entries

  validates_is_unique :title

  def self.group_for_archive
    elems = Entry.all(:order => [:created_at.desc])
    group_by(elems) do |e| 
      Time.gm(e.created_at.year, e.created_at.month)
    end
  end

  # Returns all elements for the index page
  def self.all_for_index
    Entry.all(:order => [:created_at.desc], :limit => 10)
  end

  private
  def self.group_by(sorted_array, &block)
    groups = []
    prev   = nil
    sorted_array.each do |elem|
      value = yield elem
      if prev.nil? || value == prev
        append_to_lastgroup(groups, value, elem)
        prev = value
      else
        append_to_group(groups, value, elem)
        prev = value
      end
    end
    groups
  end

  def self.groups_empty?(groups)
    groups.size == 0 || groups.last.size == 0
  end

  def self.append_to_lastgroup(groups, value, elem)
    if groups_empty?(groups)
      groups << [ value, [ elem ]]
    else
      groups.last[1] << elem
    end
  end

  def self.append_to_group(groups, value, elem)
    groups << [value, [ elem ]]
  end
end
