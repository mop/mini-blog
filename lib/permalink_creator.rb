module PermalinkCreator
  module PermalinkCreatorMethodGroups
  end
  module PermalinkCreatorMethods
    # Creates the permalink from the title-attribute and stores it into the
    # permalnik attribute
    # ---
    # @public
    def create_permalink
      self.permalink = title.downcase.gsub(/['"]/, '').gsub(/ /, '-')
    end
  end

  def self.included(klass)
    klass.send(:before, :save, :create_permalink)
    klass.extend PermalinkCreatorMethodGroups
    klass.send(:include, PermalinkCreatorMethods)
  end
end
