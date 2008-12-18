module Merb
  module GlobalHelpers
    # Returns the name of the comment. If a url is given a link is
    # made out of the name. Otherwise simply the name is returned.
    def comment_title(comment)
      if comment.url != ""
        "<a href=\"#{h(comment.url)}\">#{h(comment.name)}</a>"
      else
        h(comment.name)
      end
    end

    # Yields the blog if you're an admin
    def admin(&block)
      block.call if logged_in?
    end
  end
end
