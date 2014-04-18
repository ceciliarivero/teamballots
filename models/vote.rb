class Vote < Ohm::Model
  attribute :date
  attribute :rating

  index :user_id

  reference :user, :User
  reference :choice, :Choice
end
