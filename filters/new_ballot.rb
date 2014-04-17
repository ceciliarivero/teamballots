class NewBallot < Scrivener
  attr_accessor :title, :description, :start_date, :end_choices_date,
  :end_date, :status

  def validate
    assert_present :title
    assert_present :description
    assert_present :end_choices_date
    assert_present :end_date
  end
end
