require 'dm-validations'
require 'markdown_filter'
require 'permalink_creator'

# This class represents a blog-entry
class Entry
  include DataMapper::Resource
  include PermalinkCreator      # create the permalink from :title 
  include MarkdownFilter        # we are using markdown here

  # ==== Properties
  property :id,            Integer,  :serial   => true
  property :title,         String,   :nullable => false
  property :text,          Text,     :nullable => false
  property :html_text,     Text,     :lazy => false
  property :created_at,    DateTime, :nullable => false, 
                                     :default => lambda { |r, p| Time.now }
  property :permalink,     String

  # ==== Associations
  has n, :comments

  # ==== Validations
  validates_is_unique :title

  # ==== Custom Code

  # This method returns the grouping for the entry-archive
  #
  # ==== Returns
  # Array[Array[DateTime, Array[Entry]]]::
  #   An Array of an two-sized Array is returned. The first element of the
  #   array is the date (month + year) to which the entry belongs to and 
  #   the second element contains all the entries which are made in this
  #   timespan.
  #
  # ==== Example
  # Entry.group_for_archive
  # # => [ 
  # #  [ Time<Month: 11, Year: 2007, [ Entry1, Entry2, ... ] ], 
  # #  [ Time<Month: 12, Year: 2007, [ Entry5, Entry6, ...], ], ... ]
  # ---
  # @public
  def self.group_for_archive
    elems = Entry.all(:order => [:created_at.desc])
    group_by(elems) do |e| 
      Time.gm(e.created_at.year, e.created_at.month)
    end
  end

  # Returns all elements for the index page
  #
  # ==== Returns
  # Array[Entry]::
  #   A list of the 10 most recent entries is returned.
  # ---
  # @public
  def self.all_for_index
    Entry.all(:order => [:created_at.desc], :limit => 10)
  end

  private
  # Groups the sorted_array by the given block
  #
  # ==== Parameters
  # sorted_array<Array>:: 
  #   This _must_ be an sorted array. The sort key should be the same which 
  #   you are using in the block
  # block<Proc>::
  #   This block gets each element of the sorted array passed as parameters
  #   (only one at a time!). It must return an value which should be used for
  #   detecting whether the next element in the array belongs to the same group
  #   as the previouse one.
  #
  # ==== Returns
  # Array[Array[value_from_block, Array[value_of_entries_of_array]]]::
  #   The grouped elements are returned in an array so that the sorting-order
  #   is preserved.
  # ---
  # @private
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

  # Returns true if the given groups-array is empty
  #
  # ==== Parameters
  # groups<Array[Array[value, Array[value]]]>::
  #   If the size of the first element is 0 or if the last-tuple isn't existing
  #   (the size of it is 0) then the groups are empty
  #
  # ==== Returns
  # Boolean::
  #   true if the group is empty, otherwise false.
  # ---
  # @private
  def self.groups_empty?(groups)
    groups.size == 0 || groups.last.size == 0
  end

  # Appends the given element to the last group, which hash the given value as
  # key. If the groups are empty a new group is created with the given value.
  #
  # ==== Parameters
  # groups<Array[Array[value, Array[value]]]>::
  #   This is the pseudo-hash used for storing the key and values in a sorted
  #   order.
  # value<Object>::
  #   This element represents the key of the pseudo hash
  # elem<Object>::
  #   This element represents one element of the value-array for the given hash
  # ---
  # @private
  def self.append_to_lastgroup(groups, value, elem)
    if groups_empty?(groups)
      groups << [ value, [ elem ]]
    else
      groups.last[1] << elem
    end
  end

  # This method is used to add the key-value pair to the pseudo hash as a new
  # group.
  #
  # ==== Parameters
  # groups<Array[Array[value, Array[value]]]>::
  #   This is the pseudo-hash used for storing the key and values in a sorted
  #   order.
  # value<Object>::
  #   This element represents the key of the pseudo hash
  # elem<Object>::
  #   This element represents one element of the value-array for the given hash
  # ---
  # @private
  def self.append_to_group(groups, value, elem)
    groups << [value, [ elem ]]
  end
end
