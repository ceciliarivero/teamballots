class NewVote < Scrivener
  attr_accessor :date, :rating

  def validate
    assert_member(:rating, (0..10))
  end
end
