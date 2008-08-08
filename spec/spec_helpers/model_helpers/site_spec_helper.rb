module SiteSpecHelper
  module SiteSpecGroupMethods
    def model_class
      Site
    end
    
    def controller_class
      Sites
    end

    def cached_time
      @@time ||= DateTime.now
    end

    def valid_attributes(params={})
      { 
        :title      => 'title',
        :text       => 'text',
        :created_at => cached_time
      }.merge(params)
    end

    def update_attributes(params={})
      { 
        :title      => 'title',
        :text       => 'text',
        :created_at => cached_time.to_s
      }.merge(params)
    end
  end

  module SiteSpecMethods
  end

  def self.included(klass)
    klass.extend(SiteSpecGroupMethods)
    klass.send(:include, SiteSpecGroupMethods) # Hack!?
    klass.send(:include, SiteSpecMethods)
  end
end

