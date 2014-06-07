class NewChoice < Scrivener
  attr_accessor :date, :title, :added_by

  def validate
    assert_present :title
    assert_present :added_by
  end
end
