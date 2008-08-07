module CustomEntryMatchers
  class LinkMatcher
    include Merb::Test::ViewHelper
    include Merb::Test::RouteHelper
    def initialize(url)
      @url = url
    end

    def matches?(target)
      @target = target
      @target.should have_tag(
        :a,
        :href => "#{path_prefix}#{@url}"
      )
      true
    end

    def failure_message
      "Error, #{@target} is not a correct permalink for the given entry"
    end

    def path_prefix
      Merb.config[:path_prefix]
    end
  end

  def have_permalink(entry)
    LinkMatcher.new(url(:permalink_entry, entry))
  end

  def have_link(link)
    LinkMatcher.new(link)
  end
end
