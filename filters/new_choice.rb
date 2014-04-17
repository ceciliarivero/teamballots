class NewChoice < Scrivener
  attr_accessor :date, :title

  def validate
    assert_present :title
  end
end
