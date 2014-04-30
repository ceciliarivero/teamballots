class Group < Ohm::Model
  attribute :name

  index :user_id

  reference :user, :User

  set :voters, :User
end
