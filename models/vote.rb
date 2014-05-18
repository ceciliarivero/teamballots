class Vote < Ohm::Model
  attribute :date
  attribute :rating

  index :user_id

  reference :user, :User
  reference :choice, :Choice

  def posted_at
    return Time.at(date.to_i).strftime("%e/%m/%Y - %l:%M %p")
  end
end
