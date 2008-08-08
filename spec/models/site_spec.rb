require File.join( File.dirname(__FILE__), "..", "spec_helper" )

describe Site do
  include SiteSpecHelper
  include ValidationHelper
  include MarkdownHelper
  include PermalinkHelper

  it_should_validate_required_for(:title, :text, :created_at)
  it_should_assign_attributes
  it_should_create_permalinks_on :title
  it_should_cache_markdown :text, :html_text
  it_should_verify_uniqueness_of :title => 'test'
end
