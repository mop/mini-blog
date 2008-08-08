module EntrySpecHelper
  module EntrySpecGroupMethods
    def model_class
      Entry
    end
    
    def controller_class
      Entries
    end
    
    def cached_time
      @@time ||= DateTime.now
    end

    def valid_attributes(params={})
      { 
        :title      => 'Hello i\'m a very long title with whitespaces',
        :text       => 'text',
        :created_at => cached_time
      }.merge(params)
    end

    def update_attributes(params={})
      { 
        :title      => 'Hello i\'m a very long title with whitespaces',
        :text       => 'text',
        :created_at => cached_time.to_s
      }.merge(params)
    end
  end
  module EntrySpecMethods
  end

  def self.included(klass)
    klass.extend(EntrySpecGroupMethods)
    klass.send(:include, EntrySpecGroupMethods)
    klass.send(:include, EntrySpecMethods)
  end
end

