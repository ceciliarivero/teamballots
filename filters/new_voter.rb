class NewVoter < Scrivener
  attr_accessor :email

  def validate
    assert_present :email
  end
end
