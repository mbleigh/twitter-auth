TwitterAuth
===========

TwitterAuth is a plugin to provide a standard authentication stack using Twitter 
as an SSO provider. This is obviously most useful and therefore targeted at
apps that intend to heavily use the Twitter API.

**Note:** TwitterAuth uses Rails Engines functionality from Rails 2.3 and is
therefore incompatible with earlier versions of Rails.

Getting Started
---------------

First, install either by gem or by plugin:

    config.gem 'mbleigh-twitter-auth', :source => 'http://gems.github.com/'
    
OR
    
    script/plugin install git://github.com/mbleigh/twitter-auth.git

Next, to get started, you will need to generate the migration and model 
that TwitterAuth uses for its User. It's simple:

    script/generate migration twitter_auth
    
If you look in the migration you will see that there are some information
fields pre-populated (name, location, etc). These will automatically be
retrieved from Twitter at each login and therefor kept both accessible
and fresh for your usage. If you remove any of these fields they will be
ignored when the Twitter profile is pulled down.

Believe it or not, that's it! You now have access to the standard suite
of restful-auth controller helpers such as:

* login_required
* current_user
* logged_in?

And you also have the ability to login through the built-in SessionController.
Just run the app and point your browser to '/login' to get started! You don't
need to sign up because it will automatically create new users if the logging
in user has never logged in before.

Caveats
-------

This is **extremely alpha** code and has not been thoroughly spec'ed or even
inspected. Use at your own risk as the functionality is likely to change
drastically even in the near future.


Copyright (c) 2009 [Michael Bleigh](http://www.mbleigh.com) and [Intridea, Inc.](http://www.intridea.com/), released under the MIT license
