class Vote < Ohm::Model
  attribute :date
  attribute :rating

  reference :user, :User
  reference :choice, :Choice
end
