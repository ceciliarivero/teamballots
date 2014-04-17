class Comment < Ohm::Model
  attribute :date
  attribute :message

  def commented_at
    return Time.at(date.to_i).strftime("%e/%m/%Y - %l:%M %p")
  end

  reference :user, :User
  reference :ballot, :Ballot
end
