TwitterAuth
===========

TwitterAuth aims to provide a complete authentication and API access solution for creating Twitter applications in Rails. It provides a generator and all of the necessary components to use Twitter as the sole authentication provider for an application using either Twitter's OAuth or HTTP Basic authentication strategies.

Installation
============

You can include TwitterAuth as a gem in your project like so:

    config.gem 'mbleigh-twitter-auth', :source => 'http://gems.github.com'

Or you can install it as a traditional Rails plugin:

    script/plugin install git://github.com/mbleigh/twitter-auth.git

Note that because TwitterAuth utilizes Rails Engines functionality introduced in Rails 2.3, it will not work with earlier versions of Rails.

Usage
=====

*NOTE:* HTTP Basic strategy is not yet supported. Please only use OAuth until this message is removed.

To utilize TwitterAuth in your application you will need to run the generator:

    script/generate twitter_auth --strategy [oauth|basic]

This will generate a migration as well as set up the stubs needed to use the Rails Engines controllers and models set up by TwitterAuth. It will also create a User class that inherits from TwitterUser, abstracting away all of the Twitter authentication functionality and leaving you a blank slate to work with for your application.

Usage Basics
------------

*TwitterAuth* borrows heavily from [Restful Authentication](http://github.com/technoweenie/restful-authentication) for its API because it's simple and well-known. Here are some of the familiar methods that are available:

* `login_required`: a before filter that can be added to a controller to require that a user logs in before he/she can view the page.
* `current_user`: returns the logged in user if one exists, otherwise returns `nil`.
* `logged_in?`: true if logged in, false otherwise.
* `redirect_back_or_default(url)`: redirects to the location where `store_location` was last called or the specified default URL.
* `store_location`: store the current URL for returning to when a `redirect_back_or_default` is called.
* `authorized?`: override this to add fine-grained access control for when `login_required` is already called.

Customizing TwitterAuth
-----------------------

There are a number of hooks to extend the functionality of TwitterAuth. Here is a brief description of each of them.

### Controller Methods

TwitterAuth provides some default controller methods that may be overridden in your `ApplicationController` to behave differently.

* `authentication_failed(message)`: called when Twitter authorization has failed during the process. By default, simply redirects to the site root and sets the `flash[:error]`.
* `authentication_succeeded(message=default)`: called when Twitter authorization has completed successfully. By default, simply redirects to the site root and sets the `flash[:notice]`.
* `access_denied`: what happens when the `login_required` before filter fails. By default it stores the current location to return to and redirects to the login process.


Copyright
---------

**TwitterAuth** is Copyright (c) 2009 [Michael Bleigh](http://www.mbleigh.com) and [Intridea, Inc.](http://www.intridea.com/), released under the MIT License.

TwitterAuth is not affiliated with Twitter, Inc.
