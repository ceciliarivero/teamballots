class NewMessage < Scrivener
  attr_accessor :email, :body

  def validate
    assert_present :email
    assert_present :body
  end
end
