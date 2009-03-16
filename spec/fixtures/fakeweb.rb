# This is where we fake out all of the URLs that we
# will be calling as a part of this spec suite.
# You must have the 'fakeweb' gem in order to run
# the tests for TwitterAuth.
#
# gem install 'mbleigh-fakeweb'

require 'fake_web'

FakeWeb.allow_net_connect = false

FakeWeb.register_uri(:post, 'https://twitter.com:443/oauth/request_token', :string => 'oauth_token=faketoken&oauth_token_secret=faketokensecret')

FakeWeb.register_uri(:post, 'https://twitter.com:443/oauth/access_token', :string => 'oauth_token=fakeaccesstoken&oauth_token_secret=fakeaccesstokensecret')
