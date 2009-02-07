class User < TwitterAuth::GenericUser
  # Because Rails 2.3 does not allow for simple
  # overriding of an Engine class from a samely
  # named model in the app, this is instead
  # inheriting from a GenericUser class that
  # already utilizes the 'users' table.
end