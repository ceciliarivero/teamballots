class EditUser < Scrivener
  attr_accessor :name, :username, :email, :gravatar,
  :password, :password_confirmation

  def validate
    assert_present :name
    assert_format :username, /\A([a-zA-Z]|_|\.|-|\d)+\z/
    assert_email :email

    unless password.nil?
      assert password.length > 5, [:password, :too_small]
      assert password == password_confirmation, [:password, :not_confirmed]
    end
  end
end
