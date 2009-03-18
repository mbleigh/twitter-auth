class User < TwitterAuth::<%= options[:oauth] ? "Oauth" : "Basic" %>User
  # Extend and define your user model as you see fit.
  # All of the authentication logic is handled by the 
  # parent TwitterAuth user class.
end
