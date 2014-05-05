module BallotHelpers
  def posted_at(start_date)
    return Time.at(start_date.to_i).strftime("%e/%m/%Y - %l:%M %p")
  end

  def end_choices_at(end_choices_date)
    return Time.at(end_choices_date.to_i).strftime("%e/%m/%Y - %l:%M %p")
  end

  def closes_at(end_date)
    return Time.at(end_date.to_i).strftime("%e/%m/%Y - %l:%M %p")
  end
end
