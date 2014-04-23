class NewComment < Scrivener
  attr_accessor :date, :message

  def validate
    assert_present :message
  end
end
