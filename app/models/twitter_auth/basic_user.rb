module TwitterAuth
  class BasicUser < TwitterAuth::GenericUser
    attr_protected :cryped_password, :salt
  end
end

