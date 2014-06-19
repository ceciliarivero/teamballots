class Choice < Ohm::Model
  include Ohm::Callbacks

  attribute :date
  attribute :title
  attribute :comment
  attribute :added_by

  index :added_by

  reference :user, :User
  reference :ballot, :Ballot

  collection :votes, :Vote

  def before_delete
    votes.each(&:delete)

    super
  end
end
