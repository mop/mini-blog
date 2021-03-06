# Merb::Router is the request routing mapper for the merb framework.
#
# You can route a specific URL to a controller / action pair:
#
#   r.match("/contact").
#     to(:controller => "info", :action => "contact")
#
# You can define placeholder parts of the url with the :symbol notation. These
# placeholders will be available in the params hash of your controllers. For example:
#
#   r.match("/books/:book_id/:action").
#     to(:controller => "books")
#   
# Or, use placeholders in the "to" results for more complicated routing, e.g.:
#
#   r.match("/admin/:module/:controller/:action/:id").
#     to(:controller => ":module/:controller")
#
# You can also use regular expressions, deferred routes, and many other options.
# See merb/specs/merb/router.rb for a fairly complete usage sample.

Merb.logger.info("Compiling routes...")
Merb::Router.prepare do |r|
  # RESTful routes

  r.match('/entries/archive').to(
    :controller => 'entries',
    :action     => 'archive'
  ).name(:archive_entries)

  r.resources :entries do |entry|
    entry.resources :comments
  end

  r.resources :sessions
  r.resources :sites

  r.match('/entries/:id/:permalink').to(
    :controller => 'entries',
    :action     => 'show',
    :id         => ':id',
    :permalink  => ':permalink'
  ).name(:permalink_entry)

  r.match('/sites/:id/:permalink').to(
    :controller => 'sites',
    :action     => 'show',
    :id         => ':id',
    :permalink  => ':permalink'
  ).name(:permalink_site)

  r.match('/').to(:controller => 'entries', :action => 'index')

  r.match('/markdown_preview').to(
    :controller => 'markdown_converter',
    :action     => 'index'
  ).name(:markdown_preview)

  r.match('/markdown_preview/preview').to(
    :controller => 'markdown_converter',
    :action     => 'preview'
  ).name(:markdown_preview_save)

  # This is the default route for /:controller/:action/:id
  # This is fine for most cases.  If you're heavily using resource-based
  # routes, you may want to comment/remove this line to prevent
  # clients from calling your create or destroy actions with a GET
  r.default_routes
  
  # Change this for your home page to be available at /
  # r.match('/').to(:controller => 'whatever', :action =>'index')
end
