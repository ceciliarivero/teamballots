class Ballot < Ohm::Model
  include Ohm::Callbacks

  attribute :start_date
  attribute :end_choices_date
  attribute :end_date
  attribute :title
  attribute :description
  attribute :created_by

  index :created_by

  reference :user, :User

  collection :choices, :Choice
  collection :comments, :Comment

  set :voters, :User

  def before_delete
    choices.each(&:delete)
    comments.each(&:delete)

    voters.each do |user|
      user.ballots.delete(self)
    end

    super
  end
end
