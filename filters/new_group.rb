class NewGroup < Scrivener
  attr_accessor :name

  def validate
    assert_present :name
  end
end
