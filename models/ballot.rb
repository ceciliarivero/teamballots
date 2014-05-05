class Ballot < Ohm::Model
  include Ohm::Callbacks

  attribute :start_date
  attribute :end_choices_date
  attribute :end_date
  attribute :title
  attribute :description
  attribute :created_by
  attribute :status

  index :created_by
  index :status?

  def status?
    time = Time.new.to_i

    if time < end_choices_date.to_i && time < end_date.to_i
      # self.status = "active"
      return "active"
    elsif time > end_choices_date.to_i && time < end_date.to_i
      # self.status = "voting_only"
      return "voting_only"
    else
      # self.status = "closed"
      return "closed"
    end
  end

  def posted_at
    return Time.at(start_date.to_i).strftime("%e/%m/%Y - %l:%M %p")
  end

  def end_choices_at
    return Time.at(end_choices_date.to_i).strftime("%e/%m/%Y - %l:%M %p")
  end

  def closes_at
    return Time.at(end_date.to_i).strftime("%e/%m/%Y - %l:%M %p")
  end

  def before_delete
    choices.each(&:delete)
    comments.each(&:delete)

    voters.each do |user|
      user.ballots.delete(self)
    end

    super
  end

  reference :user, :User

  collection :choices, :Choice
  collection :comments, :Comment

  set :voters, :User
end
