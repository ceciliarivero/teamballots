class NewComment < Scrivener
  attr_accessor :date, :message, :added_by

  def validate
    assert_present :message
    assert_present :added_by
  end
end
