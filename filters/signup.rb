class Signup < Scrivener
  attr_accessor :name, :username, :email, :gravatar, :password, :password_confirmation

  def validate
    if assert_present(:username)
      assert(User.fetch(username).nil?, [:username, :not_unique])
      assert_format :username, /\A([a-zA-Z]|_|\.|-|\d)+\z/
    end

    if assert_email(:email)
      assert(User.fetch(email).nil?, [:email, :not_unique])
    end

    assert_present :name
    assert password.length > 5, [:password, :too_small]
    assert password == password_confirmation, [:password, :not_confirmed]
  end

  def create
    attrs = attributes
    attrs.delete(:password_confirmation)
    User.create(attrs)
  end
end
