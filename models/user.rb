class User < Ohm::Model
  include Shield::Model
  include Ohm::Callbacks

  attribute :name
  attribute :username
  attribute :email
  attribute :crypted_password
  attribute :gravatar

  unique :username
  unique :email

  def self.fetch(identifier)
    with(:email, identifier) || with(:username, identifier)
  end

  def before_delete
    comments.each(&:delete)

    ballots.each do |ballot|
      ballot.voters.delete(self)
    end

    super
  end

  collection :comments, :Comment
  set :ballots, :Ballot
end
