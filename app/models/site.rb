class Site
  include DataMapper::Resource
  include MarkdownFilter
  include PermalinkCreator
  
  property :id,         Integer,  :serial => true
  property :title,      String,   :nullable => false
  property :text,       Text,     :nullable => false
  property :created_at, DateTime, :nullable => false
  property :html_text,  Text
  property :permalink,  String

  validates_is_unique :title
end
