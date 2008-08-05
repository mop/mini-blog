module CommentSpecHelper
  module CommentSpecGroupMethods
    def model_class
      Comment
    end
    
    def controller_class
      Comments
    end
    
    def required_fields
      [ :name, :text ]
    end
    
    def cached_time
      @@time ||= DateTime.now
    end
    
    def valid_attributes(params={})
      {
        :name       => 'tester',
        :url        => 'http://test.at',
        :mail       => 'test@test.at',
        :text       => "## comment \nsome text",
        :created_at => cached_time
      }.merge(params)
    end

    def update_attributes(params={})
      {
        :name       => 'tester',
        :url        => 'http://test.at',
        :mail       => 'test@test.at',
        :text       => "## comment \nsome text",
        :created_at => cached_time.to_s
      }.merge(params)
    end
  end

  module CommentSpecMethods
  end

  def self.included(klass)
    klass.extend(CommentSpecGroupMethods)
    klass.send(:include, CommentSpecGroupMethods)
    klass.send(:include, CommentSpecMethods)
  end
end
