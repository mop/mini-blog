require File.join(File.dirname(__FILE__), "..", 'spec_helper.rb')

def path_prefix
  Merb.config[:path_prefix]
end

describe Comments do

  include CommentSpecHelper
  include ResourceHelper

  it_should_be_resourceful(
    :auth_method  => :logged_in?,
    :auth_actions => [ :update, :edit, :destroy, :index, :show ],
    :nested_in    => :entries,
    :redirect_destroy_path => "#{path_prefix}/entries/1",
    :redirect_update_path  => "#{path_prefix}/entries/1",
    :redirect_create_path  => "#{path_prefix}/entries/1",
    :excludes => [:index, :show]
  )
end
