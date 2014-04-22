class Vote < Ohm::Model
  attribute :date
  attribute :rating

  index :user_id

  def posted_at
    return Time.at(date.to_i).strftime("%e/%m/%Y - %l:%M %p")
  end

  reference :user, :User
  reference :choice, :Choice
end
