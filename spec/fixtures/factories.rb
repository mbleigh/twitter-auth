require 'factory_girl'

Factory.define(:twitter_oauth_user, :class => User) do |u|
  u.twitter_id { User.count + 1 }
  u.login 'twitterman'
  u.access_token 'fakeaccesstoken'
  u.access_secret 'fakeaccesstokensecret'
  
  u.name 'Twitter Man'
  u.description 'Saving the world for all Twitter kind.'
end

Factory.define(:twitter_basic_user, :class => User) do |u|
  u.twitter_id { User.count + 1 }
  u.login 'twitterman'
  u.password 'test'

  u.name 'Twitter Man'
  u.description 'Saving the world for all Twitter kind.'
end
