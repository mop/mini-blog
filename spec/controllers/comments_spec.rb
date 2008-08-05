require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

describe Comments do
  include CommentSpecHelper
  include ResourceHelper

  it_should_be_resourceful(
    :auth_method  => :logged_in?,
    :auth_actions => [ :update, :edit, :destroy, :index, :show ],
    :nested_in    => :entries
  )
end
