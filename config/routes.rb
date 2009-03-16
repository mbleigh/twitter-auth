ActionController::Routing::Routes.draw do |map|
  map.resource :session
  map.oauth_callback '/oauth_callback', :controller => 'sessions', :action => 'oauth_callback'
end
