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

  def status
    time = Time.new.to_i

    if time < end_choices_date.to_i && time < end_date.to_i
      return "Active"
    elsif time > end_choices_date.to_i && time < end_date.to_i
      return "Voting only"
    else
      return "Closed"
    end
  end

  def before_delete
    choices.each(&:delete)
    comments.each(&:delete)

    voters.each do |user|
      user.ballots.delete(self)
    end

    super
  end
end
