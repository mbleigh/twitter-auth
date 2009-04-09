# Gem Dependencies
config.gem 'oauth'
config.gem 'ezcrypto'

require 'json'
require 'twitter_auth'
require 'twitterdispatch/lib/twitterdispatch'

RAILS_DEFAULT_LOGGER.info("** TwitterAuth initialized properly.")
