class Comment
  include DataMapper::Resource
  before :save do
    # escape evil html
    self.text = self.text.gsub(/&/, "&amp;").gsub(/\"/, "&quot;").
      gsub(/>/, "&gt;").gsub(/</, "&lt;") 
  end
  include MarkdownFilter

  property :id, Serial
  property :name, String, :nullable => false
  property :mail, String
  property :url, String
  property :text, Text, :nullable => false
  property :html_text, Text
  property :created_at, DateTime

  belongs_to :entry
end
