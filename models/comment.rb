class Comment < Ohm::Model
  attribute :date
  attribute :message
  attribute :added_by

  index :added_by

  reference :user, :User
  reference :ballot, :Ballot
end
