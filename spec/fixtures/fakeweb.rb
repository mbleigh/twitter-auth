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

FakeWeb.register_uri(:get, 'https://twitter.com:443/account/verify_credentials.json', :string => "{\"profile_image_url\":\"http:\\/\\/static.twitter.com\\/images\\/default_profile_normal.png\",\"description\":\"Saving the world for all Twitter kind.\",\"utc_offset\":null,\"favourites_count\":0,\"profile_sidebar_fill_color\":\"e0ff92\",\"screen_name\":\"twitterman\",\"statuses_count\":0,\"profile_background_tile\":false,\"profile_sidebar_border_color\":\"87bc44\",\"friends_count\":2,\"url\":null,\"name\":\"Twitter Man\",\"time_zone\":null,\"protected\":false,\"profile_background_image_url\":\"http:\\/\\/static.twitter.com\\/images\\/themes\\/theme1\\/bg.gif\",\"profile_background_color\":\"9ae4e8\",\"created_at\":\"Fri Feb 06 18:10:32 +0000 2009\",\"profile_text_color\":\"000000\",\"followers_count\":2,\"location\":null,\"id\":123,\"profile_link_color\":\"0000ff\"}")

#FakeWeb.register_uri(:get, 'https://twitter.com:443/)
