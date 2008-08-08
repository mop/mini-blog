require 'markdown_converter'
module MarkdownFilter
  module MarkdownFilterMethodGroups
  end

  module MarkdownFilterMethods
    # This method converts the markdown-string stored in the 
    # text-attribute and assigns it to the html_text-attribute
    def convert_markdown
      self.html_text = convert(text)
    end
  end

  def self.included(klass)
    klass.extend(MarkdownFilterMethodGroups)
    klass.send(:include, MarkdownConvertHelper)
    klass.send(:include, MarkdownFilterMethods)
    klass.send(:before, :save, :convert_markdown)
  end
end
