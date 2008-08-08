# This class represents a comment for an entry
class Comment
  include DataMapper::Resource

  # This before-filter escapes HTML and is used to prevent XSS-Attacks
  before :save do
    self.text = self.text.gsub(/&/, "&amp;").gsub(/\"/, "&quot;").
      gsub(/>/, "&gt;").gsub(/</, "&lt;") 
  end
  include MarkdownFilter    # the rest can be converted with markdown

  # The users shouldn't manually type the time into the comment
  before :create do
    self.created_at = Time.now
  end

  property :id,         Serial
  property :name,       String, :nullable => false
  property :mail,       String
  property :url,        String
  property :text,       Text,   :nullable => false
  property :html_text,  Text
  property :created_at, DateTime

  belongs_to :entry

  def to_json
    self.attributes.to_json
  end
end
