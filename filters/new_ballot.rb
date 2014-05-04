class NewBallot < Scrivener
  attr_accessor :start_date, :end_choices_date, :end_date,
  :title, :description, :created_by, :status

  def validate
    assert_present :title
    assert_present :description
    assert_present :end_choices_date
    assert_present :end_date

    # if assert_present(:end_date)
    #   assert(:end_date > :end_choices_date, [:end_date, :not_valid])
    # end

    # if assert_present(:end_choices_date)
    #   assert(:start_date < :end_choices_date, [:end_choices_date, :not_valid])
    # end
  end
end
