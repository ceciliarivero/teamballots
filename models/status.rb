class Status
  attr :status

  def initialize(ballot)
    @ballot = ballot
  end

  def status
    time = Time.new.to_i

    if time < @ballot.end_choices_date.to_i && time < @ballot.end_date.to_i
      return "Active"
    elsif time > @ballot.end_choices_date.to_i && time < @ballot.end_date.to_i
      return "Voting only"
    else
      return "Closed"
    end
  end
end
