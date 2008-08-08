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

    # helpers defined here available to all views.  
    def date_control(col, attrs = {})

      attrs.merge!(:name => attrs[:name] || control_name(col))
      attrs.merge!(:id   => attrs[:id]   || control_id(col))

      date = @_obj.send(col) || Time.new
      
      # TODO: Handle :selected option
      #attrs.merge!(:selected => attrs[:selected] || control_value(col))
      
      errorify_field(attrs, col)

      month_attrs = attrs.merge(
        :selected   => date.month.to_s, 
        :name       => attrs[:name] + '[month]',
        :id         => attrs[:id] + '_month',
        :collection => [1,2,3,4,5,6,7,8,9,10,11,12]
      )
      
      day_attrs = attrs.merge(
        :selected   => date.day.to_s, 
        :name       => attrs[:name] + '[day]',
        :id         => attrs[:id] + '_day',
        :collection => (1..31).to_a,
        :label      => nil
      )
      
      year_attrs = attrs.merge(
        :selected   => date.year.to_s,
        :name       => attrs[:name] + '[year]',
        :id         => attrs[:id] + '_year',
        :collection => (1970..2020).to_a,
        :label      => nil
      )
      
      optional_label(month_attrs) {
         select_field(month_attrs) 
      } + select_field(day_attrs) + select_field(year_attrs)
    end

    # Yields the blog if you're an admin
    def admin(&block)
      block.call if logged_in?
    end
  end
end
