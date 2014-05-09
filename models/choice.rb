class Choice < Ohm::Model
  include Ohm::Callbacks

  attribute :date
  attribute :title
  attribute :added_by

  index :added_by

  def before_delete
    votes.each(&:delete)

    super
  end

  reference :user, :User
  reference :ballot, :Ballot

  collection :votes, :Vote
end
