class Contact < Scrivener
  attr_accessor :email, :body

  def validate
    assert_email :email
    assert_present :body
  end
end
