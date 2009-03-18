ActionController::Routing::Routes.draw do |map|
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.resource :session
  map.oauth_callback '/oauth_callback', :controller => 'sessions', :action => 'oauth_callback'
end
