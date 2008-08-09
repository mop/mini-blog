# This class represents a 'static' site in our blogging software, in which
# markdown might be used. The sites are reachable via a permalink.
class Site
  include DataMapper::Resource
  
  # ==== Properties
  property :id,         Integer,  :serial => true
  property :title,      String,   :nullable => false
  property :text,       Text,     :nullable => false
  property :created_at, DateTime, :nullable => false
  property :html_text,  Text
  property :permalink,  String

  # ==== Validations
  validates_is_unique :title

  # ==== Custom Code
  include MarkdownFilter       # Filter the markdown from :text into :html_text
  include PermalinkCreator     # Create the permalink from :title into 
                               # :permalink
end
