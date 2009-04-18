TwitterAuth
===========

TwitterAuth aims to provide a complete authentication and API access solution for creating Twitter applications in Rails. It provides a generator and all of the necessary components to use Twitter as the sole authentication provider for an application using either Twitter's OAuth or HTTP Basic authentication strategies.

Installation
============

You can include TwitterAuth as a gem in your project like so:

    config.gem 'twitter-auth', :lib => 'twitter_auth'

Or you can install it as a traditional Rails plugin:

    script/plugin install git://github.com/mbleigh/twitter-auth.git

Note that because TwitterAuth utilizes Rails Engines functionality introduced in Rails 2.3, it will not work with earlier versions of Rails.

**NOTE:** TwitterAuth requires Rails version 2.3 or later because it makes extensive use of the new support for Rails Engines. Previous versions of Rails are not supported.

Usage
=====

To utilize TwitterAuth in your application you will need to run the generator:

    script/generate twitter_auth [--oauth (default) | --basic]

This will generate a migration as well as set up the stubs needed to use the Rails Engines controllers and models set up by TwitterAuth. It will also create a User class that inherits from TwitterUser, abstracting away all of the Twitter authentication functionality and leaving you a blank slate to work with for your application. 

Finally, it will create a configuration file in `config/twitter_auth.yml` in which you should input your OAuth consumer key and secret (if using the OAuth strategy) as well as a custom callback for development (the `oauth_callback` option is where Twitter will send the browser after authentication is complete. If you leave it blank Twitter will send it to the URL set up when you registered your application).

Sign in with Twitter
--------------------

Twitter recently implemented a convenience layer on top of OAuth called [Sign in with Twitter](http://apiwiki.twitter.com/Sign-in-with-Twitter). TwitterAuth makes use of this by default in newly generated applications by setting the `authorize_path` in `twitter_auth.yml`.

If you already have an application utilizing TwitterAuth that you would like to utilize the new system, simply add this line to your `twitter_auth.yml` in each environment:

    authorize_path: "/oauth/authenticate"

Usage Basics
------------

If you need more information about how to use OAuth with Twitter, please visit Twitter's [OAuth FAQ](http://apiwiki.twitter.com/OAuth-FAQ).

TwitterAuth borrows heavily from [Restful Authentication](http://github.com/technoweenie/restful-authentication) for its API because it's simple and well-known. Here are some of the familiar methods that are available:

* `login_required`: a before filter that can be added to a controller to require that a user logs in before he/she can view the page.
* `current_user`: returns the logged in user if one exists, otherwise returns `nil`.
* `logged_in?`: true if logged in, false otherwise.
* `redirect_back_or_default(url)`: redirects to the location where `store_location` was last called or the specified default URL.
* `store_location`: store the current URL for returning to when a `redirect_back_or_default` is called.
* `authorized?`: override this to add fine-grained access control for when `login_required` is already called.

Accessing the Twitter API
-------------------------

Obviously if you're using Twitter as an authentication strategy you probably have interest in accessing Twitter API information as well. Because I wasn't really satisfied with either of the popular Twitter API Ruby libraries ([Twitter4R](http://twitter4r.rubyforge.org) and [Twitter](http://twitter.rubyforge.org)) and also because neither support OAuth (yet), I decided to go with a simple, dependency-free API implementation.

The `User` class will have a `twitter` method that provides a generic dispatcher with HTTP verb commands available (`get`, `put`, `post`, and `delete`). These are automatically initialized to the `base_url` you specified in the `twitter_auth.yml` file, so you need only specify a path. Additionally, it will automatically append a .json extension and parse the JSON if you don't provide (it returns strings for XML because, well, I don't like XML and don't feel like parsing it).

    # This code will work with the OAuth and Basic strategies alike.
    user = User.find_by_login('mbleigh')

    user.twitter.get('/account/verify_credentials')
    # => {'screen_name' => 'mbleigh', 'name' => 'Michael Bleigh' ... }

    user.twitter.post('/statuses/update.json', 'status' => 'This is my status.')
    # => {"user"=>{"login" => "mbleigh" ... }, "text"=>"This is my status.", "id"=>1234567890 ... }

If Twitter returns something other than a 200 response code, TwitterAuth will catch it and try to raise a salient error message. The exception class is `TwitterAuth::Dispatcher::Error` if you're in the mood to catch it.

This area of the code is still a little raw, but hopefully will evolve to be a little more user-friendly as TwitterAuth matures. In the meantime, it's a perfectly workable foundation library, and the fact that it works the same with OAuth and HTTP Basic makes it all the better!

Customizing TwitterAuth
-----------------------

There are a number of hooks to extend the functionality of TwitterAuth. Here is a brief description of each of them.

### Controller Methods

TwitterAuth provides some default controller methods that may be overridden in your `ApplicationController` to behave differently.

* `authentication_failed(message)`: called when Twitter authorization has failed during the process. By default, simply redirects to the site root and sets the `flash[:error]`.
* `authentication_succeeded(message=default)`: called when Twitter authorization has completed successfully. By default, simply redirects to the site root and sets the `flash[:notice]`.
* `access_denied`: what happens when the `login_required` before filter fails. By default it stores the current location to return to and redirects to the login process.

Tips and Tricks
---------------

* If you are getting an `OpenSSL::SSL:SSLError (certificate verify failed)` you may want to [see this ticket and comments](https://mbleigh.lighthouseapp.com/projects/27783-twitterauth/tickets/6-error-on-login#ticket-6-2).

Resources
---------

* **Bug Reports:** See the [Issues Page](http://github.com/mbleigh/twitter-auth/issues) to report any problems you have using TwitterAuth.
* **Blog Post:** The [original blog post about TwitterAuth](http://intridea.com/2009/3/23/twitter-auth-for-near-instant-twitter-apps) has a tutorial as well to get you started.
* **GitHub Pages:** TwitterAuth has a [simple GitHub page](http://mbleigh.com/twitter-auth)

Copyright
---------

**TwitterAuth** is Copyright (c) 2009 [Michael Bleigh](http://www.mbleigh.com) and [Intridea, Inc.](http://www.intridea.com/), released under the MIT License.

TwitterAuth is not affiliated with Twitter, Inc.
