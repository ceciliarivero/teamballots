class NewVote < Scrivener
  attr_accessor :date, :rating

  def validate
    assert_member(:rating, (-10..10))
  end
end
