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

To utilize TwitterAuth in your application you will need to run the generator:

    script/generate twitter_auth --strategy [oauth|basic]

This will generate a migration as well as set up the stubs needed to use the Rails Engines controllers and models set up by TwitterAuth. It will also create a User class that inherits from TwitterUser, abstracting away all of the Twitter authentication functionality and leaving you a blank slate to work with for your application.

Copyright (c) 2009 (Michael Bleigh)[http://www.mbleigh.com] and (Intridea, Inc.)[http://www.intridea.com/], released under the MIT License
