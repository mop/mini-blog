module Merb
  module EntriesHelper
    def comment_title(comment)
      if comment.url != ""
        "<a href=\"#{h(comment.url)}\">#{h(comment.name)}</a>"
      elsif comment.mail != ""
        "<a href=\"mailto:#{h(comment.mail.split('@').join(" NOSPAM dot "))}\">#{h(comment.name)}</a>"
      else
        h(comment.name)
      end
    end
  end
end
