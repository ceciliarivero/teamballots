class NewVote < Scrivener
  attr_accessor :date, :rating

  def validate
    assert_numeric :rating
  end
end
